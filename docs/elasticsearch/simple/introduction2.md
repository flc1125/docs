# Elasticsearch 入门（二）

## 1. 聚合查詢

> 仅介绍简单常用的聚合，更多内容，请[自行访问](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html)（前方高能！！！）

### 1.1. 平均数

=== "Elasticsearch"

    ```js
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

=== "SQL"

    ````sql
    select avg(id) as avg_id from table;
    ````

=== "Result"

    ```js
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

### 1.2. 最大值/最小值

=== "Elasticsearch"

    ```js
    GET /index/_search?size=0
    {
      "aggs": {
        "max_id": {
          "max": {"field": "id"}
        }
      }
    }
    ```

=== "SQL"

    ```sql
    select max(id) as max_id from table;
    ```

=== "Result"

    ```js
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

### 1.3. 求和

=== "Elasticsearch"

    ```js
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

=== "SQL"

    ```sql
    select sum(id) as sum_id from table;
    ```

=== "Result"

    ```js
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

### 1.4. 总数

=== "Elasticsearch"

    ```js
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

=== "SQL"

    ```sql
    select count(id) as count_id from table;
    ```

=== "Result"

    ```js
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

### 1.5. 统计

=== "Elasticsearch"

    ```js
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

=== "SQL"

    ```sql
    select count(id), min(id), max(id), avg(id), sum(id)  from table;
    ```

=== "Result"

    ```js
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

## 2. PHP DSL 查修构造器扩展

[传送门](builder.md)

## 3. Mysql&Elasticsearch 同步

**方案架构图：**

- 原理：依靠 MySQL Binlog 监听方式，同步到 ES。 
- 该方案可实现全量、增量同步。
- 优势：
    - 实时性、高性能：依靠 Laravel 队列，即使在大量的数据，也能做到准实时。
    - 逻辑解耦：依靠 Binlog 监听，脱离业务解耦；依靠 Laravel 事件，监听逻辑解耦。
    - 稳定：截至 22 年，从 18 年上线，每日同步了千万级，稳定运行 4 年。

![](assets/sync.png)

**技术栈：**

- Lumen：Laravel 队列、Laravel 事件
- Binlog监听：https://github.com/krowinski/php-mysql-replication

**其他方案参考：**

- 业务逻辑直接编写同步代码
- 若使用 Laravel 框架，可使用 Scout 全文索引
- Logstash

> **以上方案未使用的原因：** 
> 实时性不高；耦合性过高；无法把控业务之外的数据同步；不支持物理删除同步

## 4. 作业

??? question "nginx 日志， 使用 Elasticsearch DSL 语法搜索4~5点，每5分钟的总访问量"

    === "Elasticsearch"

        ```js
        GET logstash-nginx_access_*/_search
        {
            "query": {
                "range": {
                    "@timestamp": {
                        "gte": "2018-12-20T04:00:00.000Z",
                        "lt": "2018-12-20T05:00:00.000Z"
                    }
                }
            },
            "size": 0,
            "aggs": {
                "times": {
                    "date_histogram": {
                        "field": "@timestamp",
                        "interval": "5m"
                    }
                }
            }
        }
        ```
    === "Result"

        ```js
        {
          "took": 2,
          "timed_out": false,
          "_shards": {
            "total": 15,
            "successful": 15,
            "skipped": 0,
            "failed": 0
          },
          "hits": {
            "total": 2872513,
            "max_score": 0,
            "hits": []
          },
          "aggregations": {
            "times": {
              "buckets": [
                {
                  "key_as_string": "2018-12-20T04:00:00.000Z",
                  "key": 1545278400000,
                  "doc_count": 235468
                },
                {
                  "key_as_string": "2018-12-20T04:05:00.000Z",
                  "key": 1545278700000,
                  "doc_count": 222655
                },
                {
                  "key_as_string": "2018-12-20T04:10:00.000Z",
                  "key": 1545279000000,
                  "doc_count": 234695
                },
                {
                  "key_as_string": "2018-12-20T04:15:00.000Z",
                  "key": 1545279300000,
                  "doc_count": 234562
                },
                {
                  "key_as_string": "2018-12-20T04:20:00.000Z",
                  "key": 1545279600000,
                  "doc_count": 234831
                },
                {
                  "key_as_string": "2018-12-20T04:25:00.000Z",
                  "key": 1545279900000,
                  "doc_count": 238366
                },
                {
                  "key_as_string": "2018-12-20T04:30:00.000Z",
                  "key": 1545280200000,
                  "doc_count": 249671
                },
                {
                  "key_as_string": "2018-12-20T04:35:00.000Z",
                  "key": 1545280500000,
                  "doc_count": 245436
                },
                {
                  "key_as_string": "2018-12-20T04:40:00.000Z",
                  "key": 1545280800000,
                  "doc_count": 242783
                },
                {
                  "key_as_string": "2018-12-20T04:45:00.000Z",
                  "key": 1545281100000,
                  "doc_count": 247763
                },
                {
                  "key_as_string": "2018-12-20T04:50:00.000Z",
                  "key": 1545281400000,
                  "doc_count": 243247
                },
                {
                  "key_as_string": "2018-12-20T04:55:00.000Z",
                  "key": 1545281700000,
                  "doc_count": 243036
                }
              ]
            }
          }
        }
        ```

??? question "分别使用 Elasticsearch-PHP 及 Laravel-Elasticsearch 构建查询开启中的建案ID和建案名，按ID降序，取前2条即可"
    
    === "Elasticsearch-PHP"

        ```php
        <?php
    
        use ES;
    
        $params = [
            'index' => 'build',
            'body'  => [
                'query' => [
                    'bool' => [
                        'filter' => [
                            ['term' => ['status' => 2]],
                            ['term' => ['closed' => 0]],
                            ['term' => ['checkstatus' => 1]],
                        ],
                    ],
                ],
                '_source' => ['id', 'build_name'],
                'sort'    => ['id' => 'desc'],
            ],
            'size' => 2,
        ];
    
        $results = ES::search($params);
    
        print_r($results);
        ```

    === "Elasticsearch-PHP-Result"

        ```
        Array
        (
            [took] => 1
            [timed_out] => 
            [_shards] => Array
                (
                    [total] => 5
                    [successful] => 5
                    [skipped] => 0
                    [failed] => 0
                )
    
            [hits] => Array
                (
                    [total] => 121
                    [max_score] => 
                    [hits] => Array
                        (
                            [0] => Array
                                (
                                    [_index] => build
                                    [_type] => _doc
                                    [_id] => 113030
                                    [_score] => 
                                    [_source] => Array
                                        (
                                            [id] => 113030
                                            [build_name] => 測試第三方士大夫
                                        )
    
                                    [sort] => Array
                                        (
                                            [0] => 113030
                                        )
    
                                )
    
                            [1] => Array
                                (
                                    [_index] => build
                                    [_type] => _doc
                                    [_id] => 113024
                                    [_score] => 
                                    [_source] => Array
                                        (
                                            [id] => 113024
                                            [build_name] => 學坤大神的豪宅
                                        )
    
                                    [sort] => Array
                                        (
                                            [0] => 113024
                                        )
    
                                )
    
                        )
    
                )
    
        )
        ```

    === "Laravel-Elasticsearch"

        ```php
        <?php
    
        use ES;
    
        $results = ES::index('build')
            ->select('id', 'build_name')
            ->where('status', 2)
            ->where('closed', 0)
            ->where('checkstatus', 1)
            ->take(2)
            ->orderBy('id', 'desc')
            ->get();
    
        print_r($results);
        ```

    === "Laravel-Elasticsearch-Result"

        ```
        Illuminate\Support\Collection Object
        (
            [items:protected] => Array
                (
                    [0] => stdClass Object
                        (
                            [id] => 113030
                            [build_name] => 測試第三方士大夫
                        )
    
                    [1] => stdClass Object
                        (
                            [id] => 113024
                            [build_name] => 學坤大神的豪宅
                        )
    
                )
    
        )
        ```