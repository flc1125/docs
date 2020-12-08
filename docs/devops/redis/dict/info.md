# info 系统状态说明

## 命令说明

**info 命令有三种用法：**

- `info`：部分 Redis 系统状态统计信息
- `info all`：全部 Redis 系统状态统计信息
- `info {section}`：某一块的系统状态统计信息，其中 {section} 可忽略大小写，参考值，如：memory 是查看内存信息。


**`info {section}` 中的 `{section}` 包含如下：**

| **模块名{section}** | **模块含义** |
| --- | --- |
| server | 服务器信息 |
| clients | 客户端信息 |
| memory | 内存信息 |
| persistence | 持久化信息 |
| stats | 全局统计信息 |
| replication | 主从复制信息 |
| cpu | CPU 消耗信息 |
| commandstats | 命令统计信息 |
| cluster | 集群信息 |
| keyspace | 数据库键统计信息 |

> 以下将以 Redis 6.0.6 版本做整理介绍。

## 模块说明

### server

可通过 `info server` 命令查看，一般包含 Redis 服务本身的一些信息，如：版本号、运行模式、操作系统版本、TCP 端口等。


| **属性名** | **属性值** | **属性描述** |
| --- | --- | --- |
| redis_version | 6.0.6 | Redis 服务版本 |
| redis_git_sha1 | 00000000 | Git SHA1 |
| redis_git_dirt | 0 | Git dirty flag |
| redis_build_id | 19d4277f1e8a2fed | Redis build id |
| redis_mode | standalone | **Redis 运行模式**，分为：<ul><li>Cluster：集群模式</li><li>Sentinel：主从复制模式</li><li>Standalone：单机模式</li></ul>|
| os | Linux 5.4.39-linuxkit x86_64 | Redis 所在服务器的操作系统 |
| arch_bits | 64 | 架构（32或64位） |
| multiplexing_api | epoll | Redis 所使用的的事件处理机制 |
| atomicvar_api | atomic-builtin | Redis 所使用的的原子处理机制 |
| gcc_version | 8.3.0 | 编译 Redis 时所使用的的 GCC 版本 |
| process_id | 1 | Redis 服务的进程 PID |
| run_id | 54ccf8d5279b4c41607a82ff0fa8565d46093337 | Redis 服务的标识 |
| tcp_port | 6379 | 监听端口 |
| uptime_in_seconds | 950520 | Redis 自启动以来，所运行的秒数 |
| uptime_in_days | 11 | Redis 自启动以来，所运行的天数 |
| hz | 10 | serverCron 每秒运算次数 |
| configured_hz | 10 | 服务器配置的 serverCron 每秒运算次数 |
| lru_clock | 12860155 | 以分钟为单位进行自增的时钟，用于 LRU 管理 |
| executable | /data/redis-server | Redis 服务器可执行文件的路径 |
| config_file | /data/conf/redis-6379.conf | Redis 配置文件 |

### clients

可通过 `info clients` 命令查看客户端信息，包含：连接数、阻塞命令连接数、输入输出缓冲区等相关统计信息。


| **属性名** | **属性值** | **属性描述** |
| --- | --- | --- |
| connected_clients | 1 | 当前客户端连接数（不含从机的连接） |
| client_recent_max_input_buffer | 2 | 当前客户端连接中，最大的输入缓存区列表 |
| client_recent_max_output_buffer | 0 | 当前客户端连接中，最大的输出缓存区列表 |
| blocked_clients | 0 | 正在等待阻塞命令（如BLPOP等）的客户端连接数 |
| tracking_clients | 0 | 被监控的客户端连接数 |
| clients_in_timeout_table | 0 | 客户端超时的客户端数 |

### memory

可通过 `info memory` 命令查看内存信息，包含：Redis 内存使用，系统内存使用，碎片率、内存分配器等相关统计信息。

| **属性名** | **属性值** | **属性描述** |
| --- | --- | --- |
| used_memory | 865680 | Redis 分配器分配的内存总量；即内部存储的所有数据内存占用量。 |
| used_memory_human | 845.39K | 同上：以可读格式返回 |
| used_memory_rss | 7643136 | 从操作系统的角度，Redis 进程占用的物理内存总量 |
| used_memory_rss_human | 7.29M | 同上：以可读格式返回 |
| used_memory_peak | 865680 | 内存使用的最大值，即：used_memory 的峰值 |
| used_memory_peak_human | 845.39K | 同上：以可读格式返回 |
| used_memory_peak_perc | 100.01% | used_memory/used_memory_peak 的比值 |
| used_memory_overhead | 820442 | 用于管理 Redis 内部数据结构的内存使用开销 |
| used_memory_startup | 802936 | Redis 在启动时消耗的初始内存量（字节） |
| used_memory_dataset | 45238 | 数据集内存量，used_memory-use_memory_overhead |
| used_memory_dataset_perc | 72.10% | 数据集内存占比，used_memory_dataset/(used_memory-used_memory_startup) |
| allocator_allocated | 860704 | 分配器分配的内存 |
| allocator_active | 1114112 | 分配器活跃的内存 |
| allocator_resident | 3629056 | 分配器常驻的内存 |
| total_system_memory | 2084032512 | 服务器系统内存 |
| total_system_memory_human | 1.94G | 同上：以可读格式返回 |
| used_memory_lua | 37888 | Lua 引擎所消耗的内存大小 |
| used_memory_lua_human | 37.00K | 同上：以可读格式返回 |
| used_memory_scripts | 0 |  |
| used_memory_scripts_human | 0B |  |
| number_of_cached_scripts | 0 |  |
| maxmemory | 0 | redis.comf 配置的 maxmemory 值，定义 Redis 可用的最大内存 |
| maxmemory_human | 0B | 同上：以可读格式返回 |
| maxmemory_policy | noeviction | **redis.conf 配置的淘汰策略，达到 maxmemory 的淘汰策略**，可选项：<ul><li>volatile-lru：只对设置了过期时间的key进行LRU（默认值） </li><li>allkeys-lru ： 删除lru算法的key</li><li>volatile-random：随机删除即将过期key</li><li>allkeys-random：随机删除 </li><li>volatile-ttl ： 删除即将过期的 </li><li>noeviction ：永不过期，返回错误</li></ul>|
| allocator_frag_ratio | 1.29 | 分配器的碎片率 |
| allocator_frag_bytes | 253408 | 分配器碎片大小 |
| allocator_rss_ratio | 3.26 | 分配器常驻内存比例 |
| allocator_rss_bytes | 2514944 | 分配器常驻内存大小 |
| rss_overhead_ratio | 2.11 | 常驻内存开销比例 |
| rss_overhead_bytes | 4014080 | 常驻内存开销大小 |
| mem_fragmentation_ratio | 9.27 | 内存碎片率，used_memory_rss/used_memory 比值 |
| mem_fragmentation_bytes | 6818472 | 内存碎片大小 |
| mem_not_counted_for_evict | 0 | 被驱逐的内存 |
| mem_replication_backlog | 0 | Redis 复制积压缓冲区内存 |
| mem_clients_slaves | 0 | Redis 节点客户端内存消耗 |
| mem_clients_normal | 16986 | Redis 常规客户端所使用的的内存消耗 |
| mem_aof_buffer | 0 | AOF使用的内存 |
| mem_allocator | jemalloc-5.1.0 | Redis 所使用的的内存分配器，默认为：jemalloc；编译时选择 |
| active_defrag_running | 0 | 是否激活主动碎片整理的标志(0没有,1正在运行) |
| lazyfree_pending_objects | 0,  | 0-不存在延迟释放的挂起对象 |


**说明：** 理想情况下，`used_memory_rss` 值略高于 `used_memory`，当 `used_memory_rss` 远大于 `used_memory` 时，意味着存在大量的内存碎片，可通过查看 `mem_fragmentation_ratio` 碎片率。
内存使用后， Redis 释放内存并未将内存返回给系统，可检查 `used_memory_peak` 的值。

### persistence

可通过 `info persistence` 命令查看持久化信息，包含了：RDB 和 AOF 两种持久化信息。

| **属性名** | **属性值** | **属性描述** |
| --- | --- | --- |
| loading | 0 | 是否在加载持久化文件。0为否，1为是 |
| rdb_changes_since_last_save | 53308858 | 自上次 RDB 后，Redis 数据改动条数 |
| rdb_bgsave_in_progress | 0 | 表示 RDB 的 bgsave 是否在进行中。0为否，1为是 |
| rdb_last_save_time | 1456376460 | 上次 bgsave 操作的时间戳 |
| rdb_last_bgsave_status | ok | 上次 bgsave 操作的状态 |
| rdb_last_bgsave_time_sec | 3 | 上次 bgsave 操作使用的时间（单位：秒） |
| rdb_current_bgsave_time_sec | -1 | 如果 bgsave 操作正在进行，则记录当前 bgsave 操作的使用时间(单位：秒） |
| rdb_last_cow_size | 0 |  |
| aof_enabled | 1 | 是否开启了 AOF 功能，0否，1是 |
| aof_rewrite_in_progress | 0 | 表示 AOF 的 rewrite 操作是否在进行中，0否，1是 |
| aof_rewrite_scheduled | 0 | 表示是否将要在 RDB 的 bgsave 操作结束后执行 AOF rewrite 操作 |
| aof_last_rewrite_time_sec | 0 | 上次 AOF rewrite 操作的使用时间（单位：秒） |
| aof_current_rewrite_time_sec | -1 | 如果 AOF rewrite 操作正在进行，则记录当前 AOF rewrite 所使用的的时间（单位：秒） |
| aof_last_bgrewrite_status | ok | 上次 AOF 重写操作的状态 |
| aof_last_write_status | ok | 上次 AOF 写磁盘的结果 |
| aof_last_cow_size |  |  |
| module_fork_in_progress |  |  |
| module_fork_last_cow_size |  |  |


### stats

可通过 `info stats` 命令查看 Redis 基础统计信息，包含了：连接、命令、网络、过期、同步等。


| **属性名** | **属性值** | **属性描述** |
| --- | --- | --- |
| total_connections_received | 5 | 连接过的客户端总数 |
| total_commands_processed | 29 | 执行过的命令总数 |
| instantaneous_ops_per_sec | 0 | 每秒处理命令条数 |
| total_net_input_bytes | 732 | 输入总网络流量（单位：字节） |
| total_net_output_bytes | 77050 | 输出总网络流量（单位：字节） |
| instantaneous_input_kbps | 0 | 每秒输入字节数 |
| instantaneous_output_kbps | 0 | 每秒输出字节数 |
| rejected_connections | 0 | 拒绝的连接数 |
| sync_full | 0 | 主从完全同步成功的次数 |
| sync_partial_ok | 0 | 主从部分同步成功的次数 |
| sync_partial_err | 0 | 主从部分同步失败的次数 |
| expired_keys | 0 | 过期 key 的数量 |
| expired_stale_perc | 0 |  |
| expired_time_cap_reached_count | 0 |  |
| expire_cycle_cpu_milliseconds | 2279157 |  |
| evicted_keys | 0 | 提出（超过了 maxmemory后）的key 数量 |
| keyspace_hits | 17 | 命中次数 |
| keyspace_misses | 0 | 不命中次数 |
| pubsub_channels | 0 | 当前使用中的频道数量 |
| pubsub_patterns | 0 | 当前使用中的模式数量 |
| latest_fork_usec | 0 | 最后一次 fork 操作消耗的时间（微秒） |
| migrate_cached_sockets | 0 | 记录当前 Redis 正在进行 migrate 操作的目标 Redis 个数。如：Redis A 分别向 Redis B 和 C 执行 migrate 操作，那么这个值就是 2 |
| slave_expires_tracked_keys | 0 |  |
| active_defrag_hits | 0 |  |
| active_defrag_misses | 0 |  |
| active_defrag_key_hits | 0 |  |
| active_defrag_key_misses | 0 |  |
| tracking_total_keys | 0 |  |
| tracking_total_items | 0 |  |
| tracking_total_prefixes | 0 |  |
| unexpected_error_replies | 0 |  |


### replication

可通过 `info replication` 命令查看主从复制的信息，根据主从节点，统计信息略有不同。

| **角色** | **属性名** | **属性值** | **属性描述** |
| :---: | --- | --- | --- |
| 通用 | role | maste|slave | 节点的角色 |
|  | repl_backlog_active | 1 | 复制缓冲区状态 |
|  | repl_backlog_size | 10000000 | 复制缓冲区尺寸（单位：字节） |
|  | repl_backlog_first_byte_offset | 426968955147 | 复制缓冲区起始偏移量，标识当前缓冲区范围 |
|  | repl_backlog_histlen | 10000000 | 标识复制缓冲区已存有效数据长度 |
| 主节点 | connected_slaves | 1 | 连接的从节点个数 |
|  | slave0 | slave0:ip=10.10.xx.160,port=6382,state=online,offset=426978948465,lag=1 | 连接的从节点信息 |
|  | master_repl_offset | 426978955146 | 主节点偏移量 |
| 从节点 | master_host | 10.10.x.63 | 主节点 IP |
|  | master_port | 6387 | 主节点端口 |
|  | master_link_status | up | 与主节点的连接状态 |
|  | master_last_to_seconds_ago | 0 | 主节点最后与从节点的通信时间间隔，单位：秒 |
|  | master_sync_in_progress | 0 | 从节点是否正在全量同步主节点 RDB 文件 |
|  | slave_repl_offset | 426978956171 | 复制偏移量 |
|  | slave_priority | 100 | 从节点优先级 |
|  | slave_read_only | 1 | 从节点是否只读 |
|  | connected_slaves | 0 | 连接从节点个数 |
|  | master_repl_offset | 0 | 当前从节点作为其他节点的主节点时的复制偏移量 |

**注：**主从偏移量可用来做监控，查看延迟情况。

### cpu

可通过 `info cpu` 命令查看 CPU 的信息，包含了： Redis 进程和子进程对于 CPU 消耗的信息。


| **属性名** | **属性值** | **属性描述** |
| --- | --- | --- |
| used_cpu_sys | 1453.357954 | Redis 主进程在内核态所占用的 CPU 时钟总和 |
| used_cpu_user | 435.587530 | Redis 主进程在用户态所占用的 CPU 时钟总和 |
| used_cpu_sys_children | 0.022650 | Redis 子进程在内核态所占用的 CPU 时钟总和 |
| used_cpu_user_children | 0.002500 | Redis 子进程在内核态所占用的 CPU 时钟总和 |


### commandstats


可通过 `info commandstats` 命令查看 Redis 命令统计信息，包含了： 各个命令的命令名、总次数、总耗时、平均耗时。


| **属性名** | **属性值** | **属性描述** |
| --- | --- | --- |
| cmdstat_get | calls=1,usec=3984,usec_per_call=3984.00 | get 命令的调用总次数、总耗时、平均耗时（单位：微秒） |
| cmdstat_info | calls=7,usec=45461,usec_per_call=6494.43 | set 命令的调用总次数、总耗时、平均耗时（单位：微秒） |
| …… |  |  |

### cluster

可通过 `info cluster` 命令查看集群模块的信息，只有一个信息，标识当前 Redis 集群是否启用。


| **属性名** | **属性值** | **属性描述** |
| --- | --- | --- |
| cluster_enabled | 0 | 节点是否为 cluster 模式，1是，0否 |

### keyspace


可通过 `info cpu` 命令查看每个数据库的键值统计信息。

| **属性名** | **属性值** | **属性描述** |
| --- | --- | --- |
| db0 | keys=8,expires=0,avg_ttl=0 | db0 数据库的 key 总数，带有过期时间的 key 总数，平均存活时间 |
| db1 | keys=1,expires=0,avg_ttl=0 | db1 数据库的 key 总数，带有过期时间的 key 总数，平均存活时间 |
| …… |  |  |

## 参考文档

- [Redis 官网：INFO 命令](https://redis.io/commands/INFO)
- [Redis info memory 信息说明](https://blog.csdn.net/lingeio/article/details/104670927/)