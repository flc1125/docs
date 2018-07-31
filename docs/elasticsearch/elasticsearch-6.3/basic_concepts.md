# 基本概念

本文将介绍一些 Elasticsearch 的核心概念。从一开始就理解这些概念将极大地帮助你简化学习过程。

## 近实时（NRT）

Elasticsearch 是一个近实时的搜索平台。这意味着您只需要花一点点时间（通常是一秒）从索引文档里搜索到可用的文档。

## 集群（Cluster）

A cluster is a collection of one or more nodes (servers) that together holds your entire data and provides federated indexing and search capabilities across all nodes. A cluster is identified by a unique name which by default is "elasticsearch". This name is important because a node can only be part of a cluster if the node is set up to join the cluster by its name.

Make sure that you don't reuse the same cluster names in different
environments, otherwise you might end up with nodes joining the wrong cluster.
For instance you could use `logging-dev`, `logging-stage`, and `logging-prod`
for the development, staging, and production clusters.

Note that it is valid and perfectly fine to have a cluster with only a single node in it. Furthermore, you may also have multiple independent clusters each with its own unique cluster name.


## 节点（Node）

A node is a single server that is part of your cluster, stores your data, and participates in the cluster's indexing and search
capabilities. Just like a cluster, a node is identified by a name which by default is a random Universally Unique IDentifier (UUID) that is assigned to the node at startup. You can define any node name you want if you do not want the default.  This name is important for administration purposes where you want to identify which servers in your network correspond to which nodes in your Elasticsearch cluster.

A node can be configured to join a specific cluster by the cluster name. By default, each node is set up to join a cluster named `elasticsearch` which means that if you start up a number of nodes on your network and--assuming they can discover each other--they will all automatically form and join a single cluster named `elasticsearch`.

In a single cluster, you can have as many nodes as you want. Furthermore, if there are no other Elasticsearch nodes currently running on your network, starting a single node will by default form a new single-node cluster named `elasticsearch`.


## 索引（Index）

An index is a collection of documents that have somewhat similar characteristics. For example, you can have an index for customer data, another index for a product catalog, and yet another index for order data. An index is identified by a name (that must be all lowercase) and this name is used to refer to the index when performing indexing, search, update, and delete operations against the documents in it.

In a single cluster, you can define as many indexes as you want.


## 类型（Type）

!!! wraning "Deprecated in 6.0.0."

    See [Removal of mapping types](removal-of-types.md)

A type used to be a logical category/partition of your index to allow you to store different types of documents in the same index, eg one type for users, another type for blog posts.  It is no longer possible to create multiple types in an index, and the whole concept of types will be removed in a later version.  See [Removal of mapping types](removal-of-types.md) for more.


## 文档（Document）

A document is a basic unit of information that can be indexed. For example, you can have a document for a single customer, another document for a single product, and yet another for a single order. This document is expressed in [JSON](http://json.org/) (JavaScript Object Notation) which is a ubiquitous internet data interchange format.

Within an index/type, you can store as many documents as you want. Note that although a document physically resides in an index, a document actually must be indexed/assigned to a type inside an index.

[[getting-started-shards-and-replicas]]

## 分片和副本（Shards & Replicas）

An index can potentially store a large amount of data that can exceed the hardware limits of a single node. For example, a single index of a billion documents taking up 1TB of disk space may not fit on the disk of a single node or may be too slow to serve search requests from a single node alone.

To solve this problem, Elasticsearch provides the ability to subdivide your index into multiple pieces called shards. When you create an index, you can simply define the number of shards that you want. Each shard is in itself a fully-functional and independent "index" that can be hosted on any node in the cluster.

Sharding is important for two primary reasons:

* It allows you to horizontally split/scale your content volume
* It allows you to distribute and parallelize operations across shards (potentially on multiple nodes) thus increasing performance/throughput


The mechanics of how a shard is distributed and also how its documents are aggregated back into search requests are completely managed by Elasticsearch and is transparent to you as the user.

In a network/cloud environment where failures can be expected anytime, it is very useful and highly recommended to have a failover mechanism in case a shard/node somehow goes offline or disappears for whatever reason. To this end, Elasticsearch allows you to make one or more copies of your index's shards into what are called replica shards, or replicas for short.

Replication is important for two primary reasons:

* It provides high availability in case a shard/node fails. For this reason, it is important to note that a replica shard is never allocated on the same node as the original/primary shard that it was copied from.
* It allows you to scale out your search volume/throughput since searches can be executed on all replicas in parallel.


To summarize, each index can be split into multiple shards. An index can also be replicated zero (meaning no replicas) or more times. Once replicated, each index will have primary shards (the original shards that were replicated from) and replica shards (the copies of the primary shards).
The number of shards and replicas can be defined per index at the time the index is created. After the index is created, you may change the number of replicas dynamically anytime but you cannot change the number of shards after-the-fact.

默认情况下，Elasticsearch 中的每个索引都分配了 5 个主分片和 1 个副本，这意味着集群中至少有两个节点，索引会包含5个主分片和另外5个副本分片（1个完整副本），总计为每个索引10个分片。

!!! note
    每个Elasticsearch分片都是Lucene索引。单个Lucene索引中可以包含最大数量的文档。 基于 [`LUCENE-5843`](https://issues.apache.org/jira/browse/LUCENE-5843), 限制最大文档数： `2,147,483,519` (= Integer.MAX_VALUE - 128)。 您可以使用 [cat-shards](cat-shards.md) API 监控分片大小。

有了这些，让我们开始更有趣的部分......