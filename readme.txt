百度百科 一致性哈希
See also:
http://baike.baidu.com/view/1588037.html

一致性哈希　　
一致性哈希(Consistent Hash) 
　　协议简介 
　　一致性哈希算法在1997年由麻省理工学院提出(参见0)，设计目标是为了解决因特网中的热点(Hot pot)问题，初衷和CARP十分类似。一致性哈希修正了CARP使用的简单哈希算法带来的问题，使得DHT可以在P2P环境中真正得到应用。 
　　哈希算法 
　　一致性哈希提出了在动态变化的Cache环境中，哈希算法应该满足的4个适应条件： 
　　平衡性(Balance) 
　　平衡性是指哈希的结果能够尽可能分布到所有的缓冲中去，这样可以使得所有的缓冲空间都得到利用。很多哈希算法都能够满足这一条件。 
　　单调性(Monotonicity) 
　　单调性是指如果已经有一些内容通过哈希分派到了相应的缓冲中，又有新的缓冲加入到系统中。哈希的结果应能够保证原有已分配的内容可以被映射到新的缓冲中去，而不会被映射到旧的缓冲集合中的其他缓冲区。 
　　简单的哈希算法往往不能满足单调性的要求，如最简单的线性哈希： 
　　x → ax + b mod (P) 
　　在上式中，P表示全部缓冲的大小。不难看出，当缓冲大小发生变化时(从P1到P2)，原来所有的哈希结果均会发生变化，从而不满足单调性的要求。 
　　哈希结果的变化意味着当缓冲空间发生变化时，所有的映射关系需要在系统内全部更新。而在P2P系统内，缓冲的变化等价于Peer加入或退出系统，这一情况在P2P系统中会频繁发生，因此会带来极大计算和传输负荷。单调性就是要求哈希算法能够避免这一情况的发生。 
　　分散性(Spread) 
　　在分布式环境中，终端有可能看不到所有的缓冲，而是只能看到其中的一部分。当终端希望通过哈希过程将内容映射到缓冲上时，由于不同终端所见的缓冲范围有可能不同，从而导致哈希的结果不一致，最终的结果是相同的内容被不同的终端映射到不同的缓冲区中。这种情况显然是应该避免的，因为它导致相同内容被存储到不同缓冲中去，降低了系统存储的效率。分散性的定义就是上述情况发生的严重程度。好的哈希算法应能够尽量避免不一致的情况发生，也就是尽量降低分散性。 
　　负载(Load) 
　　负载问题实际上是从另一个角度看待分散性问题。既然不同的终端可能将相同的内容映射到不同的缓冲区中，那么对于一个特定的缓冲区而言，也可能被不同的用户映射为不同的内容。与分散性一样，这种情况也是应当避免的，因此好的哈希算法应能够尽量降低缓冲的负荷。 
　　从表面上看，一致性哈希针对的是分布式缓冲的问题，但是如果将缓冲看作P2P系统中的Peer，将映射的内容看作各种共享的资源(数据，文件，媒体流等)，就会发现两者实际上是在描述同一问题。 
　　路由算法 
　　在一致性哈希算法中，每个节点(对应P2P系统中的Peer)都有随机分配的ID。在将内容映射到节点时，使用内容的关键字和节点的ID进行一致性哈希运算并获得键值。一致性哈希要求键值和节点ID处于同一值域。最简单的键值和ID可以是一维的，比如从0000到9999的整数集合。 
　　根据键值存储内容时，内容将被存储到具有与其键值最接近的ID的节点上。例如键值为1001的内容，系统中有ID为1000，1010，1100的节点，该内容将被映射到1000节点。 
　　为了构建查询所需的路由，一致性哈希要求每个节点存储其上行节点(ID值大于自身的节点中最小的)和下行节点(ID值小于自身的节点中最大的)的位置信息(IP地址)。当节点需要查找内容时，就可以根据内容的键值决定向上行或下行节点发起查询请求。收到查询请求的节点如果发现自己拥有被请求的目标，可以直接向发起查询请求的节点返回确认；如果发现不属于自身的范围，可以转发请求到自己的上行/下行节点。 
　　为了维护上述路由信息，在节点加入/退出系统时，相邻的节点必须及时更新路由信息。这就要求节点不仅存储直接相连的下行节点位置信息，还要知道一定深度(n跳)的间接下行节点信息，并且动态地维护节点列表。当节点退出系统时，它的上行节点将尝试直接连接到最近的下行节点，连接成功后，从新的下行节点获得下行节点列表并更新自身的节点列表。同样的，当新的节点加入到系统中时，首先根据自身的ID找到下行节点并获得下行节点列表，然后要求上行节点修改其下行节点列表，这样就恢复了路由关系。 
　　讨论 
　　一致性哈希基本解决了在P2P环境中最为关键的问题——如何在动态的网络拓扑中分布存储和路由。每个节点仅需维护少量相邻节点的信息，并且在节点加入/退出系统时，仅有相关的少量节点参与到拓扑的维护中。所有这一切使得一致性哈希成为第一个实用的DHT算法。 
　　但是一致性哈希的路由算法尚有不足之处。在查询过程中，查询消息要经过O(N)步(O(N)表示与N成正比关系，N代表系统内的节点总数)才能到达被查询的节点。不难想象，当系统规模非常大时，节点数量可能超过百万，这样的查询效率显然难以满足使用的需要。换个角度来看，即使用户能够忍受漫长的时延，查询过程中产生的大量消息也会给网络带来不必要的负荷。



英文WIKI
See also:
http://en.wikipedia.org/wiki/Consistent_hashing

Consistent hashing
From Wikipedia, the free encyclopedia
Jump to: navigation, search
Consistent hashing is a scheme that provides hash table functionality in a way that the addition or removal of one slot does not significantly change the mapping of keys to slots. In contrast, in most traditional hash tables, a change in the number of array slots causes nearly all keys to be remapped. By using consistent hashing, only K/n keys need to be remapped on average, where K is the number of keys, and n is the number of slots.

Contents [hide]
1 History 
2 Technique 
3 References 
4 External links 
 

[edit] History
Consistent hashing was introduced in 1997 as a way of distributing requests among a changing population of web servers. Each slot is then represented by a node in a distributed system. The addition (joins) and removal (leaves/failures) of nodes only requires K/n items to be re-shuffled when the number of slots/nodes change. More recently it has been used to reduce the impact of partial system failures in large web applications as to allow for robust caches without incurring the system wide fallout of a failure [1] [2].

More recently, consistent hashing has been applied in the design of distributed hash tables (DHTs). DHTs use consistent hashing to partition a keyspace among a distributed set of nodes, and additionally provide an overlay network which connects nodes such that the node responsible for any key can be efficiently located.

[edit] Technique
Consistent hashing is based on mapping items to a real angle (or equivalently a point on the edge of a circle). Slots correspond to angle ranges. Slots can be added or removed by either slightly readjusting all the angle ranges or just a subset of them (with the condition that every angle is assigned to one slot).























Understanding Consistent Hashing
See also:
http://www.spiteful.com/2008/03/17/programmers-toolbox-part-3-consistent-hashing/

 


?Given a resource key and a list of servers, how do you find a primary, second, tertiary (and on down the line) server for the resource?
?If you have different size servers, how do you assign each of them an amount of work that corresponds to their capacity?
?How do you smoothly add capacity to the system without downtime? Specifically, this means solving two problems: 
?How do you avoid dumping 1/N of the total load on a new server as soon as you turn it on?
?How do you avoid rehashing more existing keys than necessary?









参考资料
一致性哈希算法描述(中文)
http://www.kuqin.com/web/20080725/12289.html

Memcache英文PPT
http://lepo.it.da.ut.ee/~andrei_p/ds2008/Memcached.pdf

一致性哈希性能比较
http://www.blogjava.net/killme2008/archive/2009/03/10/258838.html

C/C++实现:
Libmemcached
http://tangent.org/552/libmemcached.html

Perl实现
Set::ConsistentHash
See also:
http://search.cpan.org/dist/Set-ConsistentHash/

一致性哈希PHP实现
See also:
http://paul.annesley.cc/
http://blog.csdn.net/mayongzhan/archive/2009/06/25/4298834.aspx

线性哈希Ruby简单实现
See also:
http://www.hyperionreactor.net/blog/simple-consistent-hash-memcache-ruby
Simple Consistent Hash for Memcache in Ruby
servers = ['memcache1', 'memcache2', 'memcache3', 'memcache4']
servers[ 'product-1'.hash % servers.size ]
servers[ 'product-1'.hash % servers.size ] => "memcache4"
servers[ 'product-2'.hash % servers.size ] => "memcache1"

See also:
http://www.mikeperham.com/2009/01/14/consistent-hashing-in-memcache-client/
idx = Zlib.crc32(key) % servers.size


一致性哈希Java实现
http://weblogs.java.net/blog/tomwhite/archive/2007/11/consistent_hash.html


Python实现
http://amix.dk/blog/viewEntry/19367

MySQL实现(基于libmemcached)
See also:
https://launchpad.net/memcached-udfs
http://hi.baidu.com/tister/blog/item/1b3e3b97f18b136555fb9615.html
http://www.onlycto.com/tech/1834/61.html

Lua实现
Luamemcached的内置函数实现
See also
http://luaforge.net/projects/luamemcached/
http://code.google.com/p/luamemcached/downloads/list


