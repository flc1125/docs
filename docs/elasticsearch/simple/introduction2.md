# Elasticsearch 入门（二）

## 聚合查詢

> 仅介绍简单常用的聚合

### 平均数

```js tab="Elasticsearch"
GET /index/_search?size=0
{
  "aggs": {
    "avg_id": {
      "avg": {"field": "id"}
    }
  },
  // "size": 0
}
```

```sql tab="SQL"
select avg(id) as avg_id from table;
```

```js tab="Result"
{
  "took": 3,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 18813,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "avg_id": {
      "value": 109519.58650932866
    }
  }
}
```

!!! tip ""

    - 一般聚合查询，可设置 `size=0`，以减少网络传输字节数，因为我们要的结果更多的仅是聚合数据。
    - DSL 语句中 `aggregations` 可简写为 `aggs`

### 最大值/最小值

```js tab="Elasticsearch"
GET /index/_search?size=0
{
  "aggs": {
    "max_id": {
      "max": {"field": "id"}
    }
  }
}
```

```sql tab="SQL"
select max(id) as max_id from table;
```

```js tab="Result"
{
  "took": 6,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 18814,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "max_id": {
      "value": 118937
    }
  }
}
```

> 最小值：`max` 替换为 `min` 即可

### 求和

```js tab="Elasticsearch"
GET /index/_search?size=0
{
  "aggs": {
    "sum_id": {
      "sum": {"field": "id"}
    }
  }
}

// 多字段汇总
{
  "aggs": {
    "sum_id": {
      "sum": {
        "script": "doc.id.value + doc.status.value"
      }
    }
  }
}
```

```sql tab="SQL"
select sum(id) as sum_id from table;
```

```js tab="Result"
{
  "took": 21,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 18814,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "sum_id": {
      "value": 2060510918
    }
  }
}
```

### 总数

```js tab="Elasticsearch"
GET /index/_search?size=0
{
  "aggs": {
    "count_id": {
      "value_count": {
        "field": "id"
      }
    }
  }
}
```

```sql tab="SQL"
select count(id) as count_id from table;
```

```js tab="Result"
{
  "took": 6,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 18814,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "count_id": {
      "value": 18814
    }
  }
}
```

!!! question "聚合的 `value_count` 方式与结果集中 `hits.total` 的区别？"

    我们看个 SQL 的例子：

    ```sql
    select count(*) from table;

    select count(name) from table;
    ```

    > Elasticsearch 的 `value_count` 与 SQL 中的指定字段汇总一样，针对字段值为 `null` 的忽略汇总

### 统计

```js tab="Elasticsearch"
GET /build/_search?size=0
{
  "aggs": {
    "stats_id": {
      "stats": {
        "field": "id"
      }
    }
  }
}
```

```sql tab="SQL"
select count(id), min(id), max(id), avg(id), sum(id)  from table;
```

```js tab="Result"
{
  "took": 14,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": 18814,
    "max_score": 0,
    "hits": []
  },
  "aggregations": {
    "stats_id": {
      "count": 18814,
      "min": 100100,
      "max": 118937,
      "avg": 109520.08706282555,
      "sum": 2060510918
    }
  }
}
```

## Elasticsearch PHP 扩展



-----------------------

## 1. 官方扩展：Elasticsearch PHP

### 1.1. 安装

```bash
composer require elasticsearch/elasticsearch
```

版本关系（Elasticsearch 服务 和 扩展包版本）

| Elasticsearch Version | Elasticsearch-PHP Branch |
| --------------------- | ------------------------ |
| >= 6.0                | 6.0                      |
| >= 5.0, < 6.0         | 5.0                      |
| >= 2.0, < 5.0         | 1.0 or 2.0               |
| >= 1.0, < 2.0         | 1.0 or 2.0               |
| <= 0.90.x             | 0.4                      |

### 1.2. 配置

```php
<?php

use Elasticsearch\ClientBuilder;

require 'vendor/autoload.php';

$hosts = [
    '192.168.1.1:9200',         // IP + Port
    '192.168.1.2',              // Just IP
    'mydomain.server.com:9201', // Domain + Port
    'mydomain2.server.com',     // Just Domain
    'https://localhost',        // SSL to localhost
    'https://192.168.1.3:9200'  // SSL to IP + Port
];

$client = ClientBuilder::create()           // Instantiate a new ClientBuilder
                    ->setHosts($hosts)      // Set the hosts
                    ->build();              // Build the client object
```

### 1.3. 使用

#### 1.3.1. 索引文档

```php
<?php
$params = [
    'index' => 'my_index',
    'type' => 'my_type',
    'id' => 'my_id',
    'body' => ['testField' => 'abc']
];

$response = $client->index($params);
print_r($response);
```

输出

```
Array
(
    [_index] => my_index
    [_type] => my_type
    [_id] => my_id
    [_version] => 1
    [created] => 1
)
```

#### 1.3.2. 获取文档

```php
<?php
$params = [
    'index' => 'my_index',
    'type' => 'my_type',
    'id' => 'my_id'
];

$response = $client->get($params);
print_r($response);
```

输出

```
Array
(
    [_index] => my_index
    [_type] => my_type
    [_id] => my_id
    [_version] => 1
    [found] => 1
    [_source] => Array
        (
            [testField] => abc
        )

)
```

#### 1.3.3. 搜索文档

```php
<?php
$params = [
    'index' => 'my_index',
    'type' => 'my_type',
    'body' => [
        'query' => [
            'match' => [
                'testField' => 'abc'
            ]
        ]
    ]
];

$response = $client->search($params);
print_r($response);
```

```
Array
(
    [took] => 1
    [timed_out] =>
    [_shards] => Array
        (
            [total] => 5
            [successful] => 5
            [failed] => 0
        )

    [hits] => Array
        (
            [total] => 1
            [max_score] => 0.30685282
            [hits] => Array
                (
                    [0] => Array
                        (
                            [_index] => my_index
                            [_type] => my_type
                            [_id] => my_id
                            [_score] => 0.30685282
                            [_source] => Array
                                (
                                    [testField] => abc
                                )
                        )
                )
        )
)
```

### 1.4. 参考

- 最新版文档：https://www.elastic.co/guide/en/elasticsearch/client/php-api/current/index.html
- 中译文档：https://www.elastic.co/guide/cn/elasticsearch/php/current/index.html

## 2. 自研扩展：Laravel Elasticsearch

### 2.1. 安装

```bash
composer require flc/laravel-elasticsearch
```

### 2.2. 配置

```php
///
```

### 2.3. 使用

#### 2.3.1 基础

```php
<?php

use Elasticsearch;

Elasticsearch::index('index_name');
```

#### 2.3.2 搜索


## Elasticsearch 同步

## 作业

??? question "搜索4~5点，每5分钟的总访问量"

    这辈子都不可能有答案