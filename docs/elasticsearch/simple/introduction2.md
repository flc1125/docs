# Elasticsearch 入门（二）

## 1. 聚合查詢

> 仅介绍简单常用的聚合，更多内容，请[自行访问](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations.html)（前方高能！！！）

### 1.1. 平均数

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

### 1.2. 最大值/最小值

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

### 1.3. 求和

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

### 1.4. 总数

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

### 1.5. 统计

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

## 2. PHP DSL 查修构造器扩展

[传送门](builder.md)

## 3. Mysql&Elasticsearch 同步

## 4. 作业

??? question "搜索4~5点，每5分钟的总访问量"

    ```js tab="Elasticsearch"
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

    ```js tab="Result"
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