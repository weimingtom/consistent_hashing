--一致性哈希
--@see http://blog.csdn.net/mayongzhan/archive/2009/06/25/4298834.aspx <br>
--     http://www.blogjava.net/killme2008/archive/2009/03/10/258838.html <br>

require"md5"

---------------------------------------------
function tostringex(v, len)
	if len == nil then len = 0 end
	local pre = string.rep('\t', len)
	local ret = ""
	if type(v) == "table" then
		if len > 5 then return "\t{ ... }" end
		local t = ""
		local keys = {}
		for k, v1 in pairs(v) do
			table.insert(keys, k)
		end
		--table.sort(keys)
		for k, v1 in pairs(keys) do
			k = v1
			v1 = v[k]
			t = t .. "\n\t" .. pre .. tostring(k) .. ":"
			t = t .. tostringex(v1, len + 1)
		end
		if t == "" then
			ret = ret .. pre .. "{ }\t(" .. tostring(v) .. ")"
		else
			if len > 0 then
				ret = ret .. "\t(" .. tostring(v) .. ")\n"
			end
			ret = ret .. pre .. "{" .. t .. "\n" .. pre .. "}"
		end
	else
		ret = ret .. pre .. tostring(v) .. "\t(" .. type(v) .. ")"
	end
	return ret
end

function TraceError(v)
	print(tostringex(v))
end
---------------------------------------------
--虚拟节点数
local replicas = 100000
--hash方法
--默认算法md5
local hasher = md5.sumhexa;
--节点记数器
local targetCount = 0
--array { position => target, ... }
local positionToTarget = {}
--因为lua的关联数组无序
--所以需要创建一个positionToTarget的副本数组array{{position,target},...}
local positionToTarget_array = {}
--array { target => [ position, position, ... ], ... }
local targetToPositions = {}
--是否已排序
local positionToTargetSorted


--添加一个节点
function addTarget(target)
	if (targetToPositions[target] ~= nil)then
		print(string.format("Target '%s' already exists.\n",target))
		return
	end

	targetToPositions[target] = {};

	-- hash the target into multiple positions
	-- 定义节点对应的若干个源,但不是全部
	for i = 0,replicas do
		local position = hasher(target .. i);
		-- lookup
		-- position本来应该是指向虚拟节点target..i,但变成指向实际节点target
		if(positionToTarget[position] == nil)then
			--新节点
			positionToTarget[position] = target
		else
			--旧节点变新节点
			positionToTarget[position] = target
			for i,v in ipairs(positionToTarget_array) do
				if v.position == position then
					table.remove(positionToTarget_array,i)
				end
			end
		end

		--维护一个相同的数组,但不是关联数组而是纯数组
		local data = {}
		data.position = position
		data.target = target
		table.insert(positionToTarget_array,data)

		-- target removal
		table.insert(targetToPositions[target], position)
	end

	positionToTargetSorted = false
	targetCount = targetCount + 1

	return
end


--加多个节点
function addTargets(targets)
	for _,target in ipairs(targets) do
		addTarget(target);
	end

	return
end

--删除节点
function removeTarget(target)
	if (targetToPositions[target] == nil)then
		print(string.format("Target '%s' does not exist.\n",target))
		return
	end

	for _,position in ipairs(targetToPositions[target]) do
		positionToTarget[position] = nil

		--删除副本
		for i,v in ipairs(positionToTarget_array) do
			if v.position == position then
				table.remove(positionToTarget_array,i)
			end
		end
	end

	targetToPositions[target] = nil;

	targetCount = targetCount - 1

	return
end

--A list of all potential targets
--@return array
--所有节点
function getAllTargets()
	local keys = {}
	for k,_ in targetToPositions do
		table.insert(keys,k)
	end

	return keys
end



-- Looks up the target for the given resource.
-- @param string $resource
-- @return string
--求节点
function lookup(resource)
	--查找第一个节点
	local targets = lookupList(resource, 1);
	if (targets == nil) then
		print('No targets exist')
		return ""
	elseif (#targets == 0) then
		print('No targets exist')
		return ""
	end

	--lua的下标从1开始
	return targets[1];
end



---
--Get a list of targets for the resource, in order of precedence.
--Up to $requestedCount targets are returned, less if there are fewer in total.
--@param string $resource
--@param int $requestedCount The length of the list to return
--@return array List of targets
--@comment 查找当前的资源对应的节点,
--节点为空则返回空,节点只有一个则返回该节点,
--对当前资源进行hash,对所有的位置进行排序,在有序的位置列上寻找当前资源的位置
--当全部没有找到的时候,将资源的位置确定为有序位置的第一个(形成一个环)
--返回所找到的节点
function lookupList(resource, requestedCount)
	if (requestedCount == nil )then
		print('Invalid count requested')
	end

	--handle no targets
	if (positionToTarget == nil or positionToTarget_array == nil)then
		return {};
	end

	if (#positionToTarget_array == 0)then
		return {};
	end

	-- optimize single target
	--优化
	--???????????????????????????
	if (targetCount == 1)then
		return array_unique(positionToTarget);
	end

    -- hash resource to a position
	resourcePosition = hasher(resource);
	--TraceError(resourcePosition)

	--lua没有逆向查找,只能用关联数组表示集合
	local results = {};
	local collect = false;

    sortPositionTargets();

	--第一次遍历大于resourcePosition的key
	--search values above the resourcePosition
	for i,v in ipairs(positionToTarget_array) do
		--start collecting targets after passing resource position
		if (collect == false and v.position > resourcePosition)then
			collect = true
		end

		--only collect the first instance of any target
		if (collect == true and in_array(v.target, results) == false)then
			table.insert(results,v.target)
		end

		--找够或找完
        --return when enough results, or list exhausted
		if (#results == requestedCount or #results == targetCount)then
			return results
		end
    end

	--第二次遍历次遍历大于resourcePosition的key
	--loop to start - search values below the resourcePosition
	for i,v in ipairs(positionToTarget_array) do
		if (in_array(v.target, results) == false)then
			table.insert(results,v.target)
		end

		-- return when enough results, or list exhausted
		if (#results == requestedCount or #results == targetCount)then
			return results;
		end
	end

	-- return results after iterating through both "parts"
	return results;
end

--lua没有由value求key的函数,自己写
function in_array(value,arr)
	for i = 1,#arr do
		if(arr[i] == value)then
			return true
		end
	end
	return false
end

--php
--array_unique(array_values($this->_positionToTarget));
--值域
function array_unique(arr)
	local value_map = {}
	local values={}
	for k,v in arr do
		value_map[v] = k
	end

	for k,v in value_map do
		insert(values, k)
	end

	return values
end


--lua没必要
--Sorts the internal mapping (positions to targets) by position
function sortPositionTargets()
--sort by key (position) if not already
	if (not positionToTargetSorted)then
		--ksort($this->_positionToTarget, SORT_REGULAR);
		--排序副本就够了
		table.sort(positionToTarget_array,function (a,b)
			--position是hash函数求出的,lua允许直接比较字符串
			return a.position < b.position
		end)
        positionToTargetSorted = true;
	end
end



addTargets({'a','b','c'})
--sortPositionTargets()
--TraceError(positionToTarget)
--TraceError(positionToTarget_array)
for i = 1,30 do
	TraceError(lookup(i))
end


print("-------------------")
--removeTarget('c')
addTargets({'a','b','c','d'})
for i = 1,10 do
	TraceError(lookup(i))
end

