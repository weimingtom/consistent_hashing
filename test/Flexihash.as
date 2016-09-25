/**  
 * Flexihash - A simple consistent hashing implementation for PHP.  
 *   
 * The MIT License  
 *   
 * Copyright (c) 2008 Paul Annesley  
 *   
 * Permission is hereby granted, free of charge, to any person obtaining a copy  
 * of this software and associated documentation files (the "Software"), to deal  
 * in the Software without restriction, including without limitation the rights  
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
 * copies of the Software, and to permit persons to whom the Software is  
 * furnished to do so, subject to the following conditions:  
 *   
 * The above copyright notice and this permission notice shall be included in  
 * all copies or substantial portions of the Software.  
 *   
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER  
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN  
 * THE SOFTWARE.  
 *   
 * @author Paul Annesley  
 * @link http://paul.annesley.cc/  
 * @copyright Paul Annesley, 2008  
 * @comment by MyZ (http://blog.csdn.net/mayongzhan)  
 */  
  
package {
	import flash.external.ExternalInterface;
	/**  
	 * A simple consistent hashing implementation with pluggable hash algorithms.  
	 *  
	 * @author Paul Annesley  
	 * @package Flexihash  
	 * @licence http://www.opensource.org/licenses/mit-license.php  
	 */  
	public class Flexihash   
	{   
	  
		/**  
		 * The number of positions to hash each target to.  
		 *  
		 * @var int  
		 * @comment ����ڵ���,����ڵ�ֲ�����������  
		 */  
		private var m_replicas:int = 64;   
	  
		/**  
		 * The hash algorithm, encapsulated in a Flexihash_Hasher implementation.  
		 * @var object Flexihash_Hasher  
		 * @comment ʹ�õ�hash���� : md5,crc32  
	   */  
		private var m_hasher:Flexihash_Hasher;   
	  
		/**  
		 * Internal counter for current number of targets.  
		 * @var int  
		 * @comment �ڵ������  
		 */  
		private var m_targetCount:int = 0;   
	  
		/**  
		 * Internal map of positions (hash outputs) to targets  
		 * @var array { position => target, ... }  
		 * @comment λ�ö�Ӧ�ڵ�,����lookup�и���λ��ȷ��Ҫ���ʵĽڵ�  
		 */  
		private var m_positionToTarget:Array = new Array();   
		
		//��������position�����������
		//һ��position��Ӧһ������ڵ㣬�������ڵ��Ӧһ���ڵ�
		private var m_positionToTarget_keys:Array = new Array();
		/**  
		 * Internal map of targets to lists of positions that target is hashed to.  
		 * @var array { target => [ position, position, ... ], ... }  
		 * @comment �ڵ��Ӧλ��,����ɾ���ڵ�  
		 */  
		private var m_targetToPositions:Array = new Array();   

		/**  
		 * Whether the internal map of positions to targets is already sorted.  
		 * @var boolean  
		 * @comment �Ƿ�������  
		 */  
		private var m_positionToTargetSorted:Boolean = false;   
	  
		/**  
		 * Constructor  
		 * @param object $hasher Flexihash_Hasher  
		 * @param int $replicas Amount of positions to hash each target to.  
		 * @comment ���캯��,ȷ��Ҫʹ�õ�hash����������ڵ���,����ڵ���Խ��,�ֲ�Խ����,������ķֲ�ʽ����Խ��  
		 */  
		public function Flexihash(hasher:Flexihash_Hasher = null,replicas:int = 0)   
		{   
			m_hasher = hasher ? hasher : new Flexihash_Crc32Hasher();   
			if (replicas > 0) m_replicas = replicas;   
		}   
	  
		/**  
		 * Add a target.  
		 * @param string $target  
		 * @chainable  
		 * @comment ��ӽڵ�,��������ڵ���,���ڵ�ֲ����������λ����  
		 */  
		public function addTarget(target:String):void   
		{   
			if (m_targetToPositions[target])   
			{   
				throw new Flexihash_Exception("Target \'" + target + "\' already exists.");   
			}   
	  
			m_targetToPositions[target] = new Array();   
	  
			// hash the target into multiple positions   
			for (var i:int = 0; i < m_replicas; i++)   
			{   
				//���������������������������һ����ð��
				//����Ϊ�˲���target�����ֵ�ʱ�򷽱�������ð�Ÿ���
				var position:String = m_hasher.hash(target.toString() + ":" + i.toString()); 
				
				//�����ֹ���ǣ�����Ҫ��
				if(m_positionToTarget[position] == null)
					m_positionToTarget[position] = target; // lookup 
					
				m_targetToPositions[target].push(position); // target removal   
				
				//����µ�����ڵ�
				m_positionToTarget_keys.push(position);
			}   

			m_positionToTargetSorted = false;   
			m_targetCount++;   
	  
			return;
		}   
	  
		/**  
		 * Add a list of targets.  
		 * @param array $targets  
		 * @chainable  
		 */  
		public function addTargets(targets:Array):void   
		{   
			for each (var target:String in targets)   
			{   
				addTarget(target);   
			}   
		
			return;
		}   
	  
		/**  
		 * Remove a target.  
		 * @param string $target  
		 * @chainable  
		 */  
		public function removeTarget(target:String):void   
		{   
			if (m_targetToPositions[target] == null)   
			{   
				throw new Flexihash_Exception("Target \'" + target + "\' does not exist.");   
			}   

			for each (var position:String in m_targetToPositions[target])   
			{   
				delete(m_positionToTarget[position]);  
				
				//��������ڵ��position
				for (var index:int = 0; index < m_positionToTarget_keys.length; index++)
				{
					if (m_positionToTarget_keys[index] == position)
					{
						m_positionToTarget_keys.splice(index, 1);
						break;
					}
				}	
				//����������ķ�������
				/*
				var index:int = m_positionToTarget_keys.indexOf(position);
				if(index >= 0)
				{
					m_positionToTarget_keys.splice(index, 1);
				}
				*/
			} 

			delete(m_targetToPositions[target]);   
		
			m_targetCount--;   
	  
			return;
		}   
	  
		/**  
		 * A list of all potential targets  
		 * @return array  
		 */  
		public function getAllTargets():Array   
		{   
			return array_keys(m_targetToPositions);  
		}   
	  
		/**  
		 * Looks up the target for the given resource.  
		 * @param string $resource  
		 * @return string  
		 */  
		public function lookup(resource:String):String   
		{   
			var targets:Array = lookupList(resource, 1);   
			if (targets.length == 0) throw new Flexihash_Exception("No targets exist");   
			return targets[0];   
		}   
	  
		/**  
		 * Get a list of targets for the resource, in order of precedence.  
		 * Up to $requestedCount targets are returned, less if there are fewer in total.  
		 *  
		 * @param string $resource  
		 * @param int $requestedCount The length of the list to return  
		 * @return array List of targets  
		 * @comment ���ҵ�ǰ����Դ��Ӧ�Ľڵ�,  
		 *          �ڵ�Ϊ���򷵻ؿ�,�ڵ�ֻ��һ���򷵻ظýڵ�,  
		 *          �Ե�ǰ��Դ����hash,�����е�λ�ý�������,�������λ������Ѱ�ҵ�ǰ��Դ��λ��  
		 *          ��ȫ��û���ҵ���ʱ��,����Դ��λ��ȷ��Ϊ����λ�õĵ�һ��(�γ�һ����)  
		 *          �������ҵ��Ľڵ�  
		 */  
		public function lookupList(resource:String, requestedCount:int):Array   
		{   
			if (!requestedCount)   
				throw new Flexihash_Exception("Invalid count requested");   
	  
			// handle no targets   
			if (m_positionToTarget == null)   
				return new Array();   
	  
			// optimize single target   
			if (m_targetCount == 1)  
			{
				return array_unique(array_values(m_positionToTarget)); 
				//or
				//return getAllTargets();
			}
	  
			// hash resource to a position   
			var resourcePosition:String = m_hasher.hash(resource);   
	  
			var results:Array = new Array();   
			var collect:Boolean = false;   
	  
			sortPositionTargets();   
	  
			// search values above the resourcePosition 
			var key:String;
			var value:String;
			
			/*
			for (key in m_positionToTarget)   
			{ 
			*/
			for (var i1:int = 0; i1 < m_positionToTarget_keys.length; i1++)
			{
				key = m_positionToTarget_keys[i1];
				
			    value = m_positionToTarget[key];
				
				// start collecting targets after passing resource position   
				if (!collect && key > resourcePosition)   
				{   
					collect = true;   
				}   
	  
				// only collect the first instance of any target   
				if (collect && !in_array(value, results))   
				{   
					results.push(value);   
				}   
	  
				// return when enough results, or list exhausted   
				if (results.length == requestedCount || results.length == m_targetCount)   
				{   
					return results;   
				}   
			}   
	  
			// loop to start - search values below the resourcePosition 
			/*
			for (key in m_positionToTarget)   
			{
			*/
			for (var i2:int = 0; i2 < m_positionToTarget_keys.length; i2++)
			{
				key = m_positionToTarget_keys[i2];
							
				value = m_positionToTarget[key];
				
				if (!in_array(value, results))   
				{   
					results.push(value);   
				}   
	  
				// return when enough results, or list exhausted   
				if (results.length == requestedCount || results.length == m_targetCount)   
				{   
					return results;   
				}   
			}   
	  
			// return results after iterating through both "parts"   
			return results;   
		}   
	  
		public function toString():String   
		{   
			var output:String = "Flexihash : ";
			var targets:Array = getAllTargets();
			for each (var target:String in targets)
			{
				output += target + ",";  
			}
			
			return output;
		}   
	  
		// ----------------------------------------   
		// private methods   
	  
		/**  
		 * Sorts the internal mapping (positions to targets) by position  
		 */  
		private function sortPositionTargets():void   
		{   
			// sort by key (position) if not already   
			if (!m_positionToTargetSorted)   
			{   
				//m_positionToTarget.sort();
				m_positionToTarget_keys.sort();
				m_positionToTargetSorted = true;   
			}   
		}   
	  
		private function array_values(arr:Array):Array
		{
			var values:Array = new Array();
			for each (var value:String in arr)
			{
				values.push(value);
			}
			return values;
		}
		
		private function array_unique(arr:Array):Array
		{
			arr.sort();
			var last_item:String = null;
			var unique:Array;
			for each(var item:String in arr)
			{
				if (item != last_item) 
					unique.push(item);
					
				last_item = item;
			}
			return unique;
		}
		
		private function in_array(value:String, arr:Array):Boolean
		{
			for each (var v:String in arr)
			{
				if (v == value)
					return true
			}
			return false;
			
			//or
			//var index:int = arr.indexOf(value)
			//if (index == -1)
			//	return false;
			//else
			//	return true;
		}
		private function array_keys(arr:Array):Array
		{
			var keys:Array = new Array(); 
			for (var key:String in arr)
			{
				keys.push(key);
			}
			return keys;
		}
	}   
	

}

	/**  
	 * An exception thrown by Flexihash.  
	 *  
	 * @author Paul Annesley  
	 * @package Flexihash  
	 * @licence http://www.opensource.org/licenses/mit-license.php  
	 */  	
	class Flexihash_Exception extends Error   
	{   
		public function Flexihash_Exception(message:String) 
		{
			super(message);
		}	
	} 
	
//��������CSDN���ͣ�ת�������������http://blog.csdn.net/mayongzhan/archive/2009/06/25/4298834.aspx