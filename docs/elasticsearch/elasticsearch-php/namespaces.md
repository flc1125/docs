# 命名空间

客户端有许多“命名空间”，通常是一些公开的可管理功能。命名空间对应 Elasticsearch 中各种可管理的 endpoint。下面是全部的命名空间：

|命名空间|功能|
|----|----|
|`indices()`|索引数据统计和显示索引信息|
|`nodes()`  |节点数据统计和显示节点信息|
|`cluster()`|集群数据统计和显示集群信息|
|`snapshot()`|对集群和索引进行拍摄快照或恢复数据|
|`cat()`    |执行Cat API命令（通常在命令行中使用）|

一些方法在不同的命名空间下均可使用。虽然返回的是同样的信息但是却属于不同的上下文环境。想知道命名空间如何运行，请看 `_stats` 的输出信息：

```php
<?php
$client = ClientBuilder::create()->build();

// Index Stats
// Corresponds to curl -XGET localhost:9200/_stats
$response = $client->indices()->stats();

// Node Stats
// Corresponds to curl -XGET localhost:9200/_nodes/stats
$response = $client->nodes()->stats();

// Cluster Stats
// Corresponds to curl -XGET localhost:9200/_cluster/stats
$response = $client->cluster()->stats();
```

上面展示了在三个不同命名空间下都调用了 `stats()` 方法。有时这些方法需要参数，这些参数的写法跟客户端中其他方法的参数写法相同。

例如，我们可以请求一个索引或多个索引的统计信息：

```php
<?php
$client = ClientBuilder::create()->build();

// Corresponds to curl -XGET localhost:9200/my_index/_stats
$params['index'] = 'my_index';
$response = $client->indices()->stats($params);

// Corresponds to curl -XGET localhost:9200/my_index1,my_index2/_stats
$params['index'] = array('my_index1', 'my_index2');
$response = $client->indices()->stats($params);
```

另外一个例子是在一个现有索引中添加别名：

```php
<?php
$params['body'] = array(
    'actions' => array(
        array(
            'add' => array(
                'index' => 'myindex',
                'alias' => 'myalias'
            )
        )
    )
);
$client->indices()->updateAliases($params);
```

注意上述例子中两个 `stats` 的调用和 `updateAlias` 的调用是接收不同格式的参数，每个方法的参数格式由相应的 API 需求来决定。`stats` API只需要一个 index 名，而 `updateAlias` 则需要一个 body，里面还要一个 actions 参数。