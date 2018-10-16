# Elasticsearch 入门

## 简介

### 什么是 Elasticsearch

- 基于 **Apache Lucene** 构建的**开源搜索引擎**
- 采用 **Java** 编写，提供简单易用的 **RESTful API**
- 轻松的**横向扩展**，可支持**PB级**的结构化或非结构化数据处理

### 应用场景

- 海量数据分析引擎
- 站内搜索引擎
- 数据仓库

一线公司实际应用场景：

- 维基百科、Github - 站内实时搜索
- 百度 - 实时日志监控平台

> 简介部分描述摘自：[瓦力老师的《ElasticSearch入门》](https://www.imooc.com/learn/889)。—— 教程版本为 5.x。本文内容基于 6.4 版本整理。

----

!!! tip ""

    **Tips：** 以下部分会列出 Elasticsearch 方式和 SQL “等价”方式便于理解。但实际应用中，部分场景，数据结果，不完全等价，仅供参考。

## 基础概念

### index

索引

> 官方传统的定义倾向数据库中 “库” 的定义，但这种比喻已被官方否定。

### type

索引类型。6.x 版本，一个index 有且只能有一个 `type`。

> 官方传统的定义倾向数据库中 “表” 的定义，但这种比喻已被官方否定。

!!! danger ""

    **官方在 6.0.0 中弃用（非删除）。 请参考 [删除映射类型](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/removal-of-types.html)**。 为兼容后续版本，**官方推荐使用 `_doc` 作为类型名**

    > 后续代码中，建议弱化 `type` 参数


### document

文档数据，类似数据库 “行” 数据。

## 基本使用

### 请求与输出

#### 请求

- 接口 API 使用 `RESTful` 规范，URI格式：`http://localhost:9200/index/<type>/<document_id>`
- `?pretty=true`：JSON 格式化

#### 输出

数据格式：`json`（也支持 `yaml`，接口地址：`?format=yaml`）

|字段|说明|
|----|----|
|`took`|请求耗时，单位：毫秒|
|`timed_out`|是否超时|
|`_shards.total`|总共查询了多少分片，含跨`index`|
|`_shards.successful`|查询成功的分片，含跨`index`|
|`hits`|匹配文档的数据结果|
|`hits.total`|匹配文档的总记录数|
|`hits.max_score`|匹配文档的最高分值|
|`hits.hits`|匹配文档的文档数据|
|`hits.hits._index`|文档所对应的索引|
|`hits.hits._type`|文档所对应的索引类型|
|`hits.hits._id`|文档所对应的文档ID|
|`hits.hits._score`|文档根据匹配对的分值|
|`hits.hits._source`|文档原始数据|
|更多...||


### 索引

- 倒排索引

    Elasticsearch 使用一种称为 **倒排索引** 的结构，它适用于快速的全文搜索。一个倒排索引由文档中所有不重复词的列表构成，对于其中每个词，有一个包含它的文档列表。

    例如，假设我们有两个文档，每个文档的 `content` 域包含如下内容：

    - The quick brown fox jumped over the lazy dog
    - Quick brown foxes leap over lazy dogs in summer
    
    ```
    Term      Doc_1  Doc_2
    -------------------------
    Quick   |       |  X
    The     |   X   |
    brown   |   X   |  X
    dog     |   X   |
    dogs    |       |  X
    fox     |   X   |
    foxes   |       |  X
    in      |       |  X
    jumped  |   X   |
    lazy    |   X   |  X
    leap    |       |  X
    over    |   X   |  X
    quick   |   X   |
    summer  |       |  X
    the     |   X   |
    ------------------------
    ```

- 创建/设置索引

    ```js
    PUT /twitter
    ```

- 删除索引

    ```js
    DELETE /twitter
    ```

- 查看索引

    ```js
    GET /twitter
    ```

### 文档

- 新增文档
    
    ```js
    PUT twitter/_doc/1
    {
        "user" : "kimchy",
        "post_date" : "2009-11-15T14:12:12",
        "message" : "trying out Elasticsearch"
    }
    ```


- 更新文档

    ```js
    // 指定文档 ID
    PUT twitter/_doc/1
    {
        "counter" : 1,
        "tags" : ["red"]
    }

    // 脚本更改（如递增）
    POST twitter/_doc/1/_update
    {
        "script" : {
            "source": "ctx._source.counter += params.count",
            "lang": "painless",
            "params" : {
                "count" : 4
            }
        }
    }
    ```

- 删除文档

    ```js
    // 指定文档 ID
    DELETE /twitter/_doc/1
    
    // 指定条件
    POST twitter/_delete_by_query
    {
      "query": { 
        "match": {
          "message": "some message"
        }
      }
    }
    ```

- 获取文档
    
    ```js
    GET twitter/_doc/1
    ```

- 搜索文档： [传送门](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/search-uri-request.html)

    ```js
    GET twitter/_search?q=user:kimchy
    ```

### 指定字段

```js tab="Elasticsearch"
{
    "_source": ["*", "user", "user.age"]
}
```

```sql tab="SQL"
select *, user from table;
```

### From / Size ： [传送门](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/search-request-from-size.html)

```js tab="Elasticsearch"
GET /_search
{
    "from" : 10,
    "size" : 20
}
```

```sql tab="SQL"
select * from table limit 10, 20;
```

!!! warning ""
    
    **`from` 默认为 0，`size` 默认为 10。 这点与 SQL 不同。**

    请注意，`from + size` 不能超过索引设置 [`index.max_result_window`](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/index-modules.html), 该值默认为10,000。

### 排序

```js
GET /my_index/_search
{
    "sort" : [
        {"post_date" : {"order" : "asc"}},
        "user",
        {"name" : "desc"},
        {"age" : "desc" },
        "_score"
    ]
}
```

> 不设置 `sort`, 默认按 `_score` 从高到低排序

## 常用 DSL

### Match 全文查询

#### match

默认匹配：[传送门](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-query.html)
    
```js tab="Elasticsearch"
GET /_search
{
    "query": {
        "match" : {
            "message" : "this is a test"
        }
    }
}
```

```sql tab="SQL"
select * from table
where message like '%this%'
    or message like '%is%'
    or message like '%a%'
    or message like '%test%';
```

> 不等价匹配的示例：如 `message` 值为 `this`。去搜索 `is`，Elasticsearch 无法匹配上；但 SQL 可匹配

#### match_phrase

短语匹配：[传送门](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-query-phrase.html)

```js tab="Elasticsearch"
GET /_search
{
    "query": {
        "match_phrase" : {
            "message" : "this is a test"
        }
    }
}
```

```sql tab="SQL"
select * from table where message like '%this is a test%';
```

#### match\_phrase\_prefix

短语前缀匹配：[传送门](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-query-phrase-prefix.html)

> 一般用于搜索框：建议搜索

```js tab="Elasticsearch"
GET /_search
{
    "query": {
        "match_phrase_prefix" : {
            "message" : "quick brown f"
        }
    }
}
```

```sql tab="SQL"
select * from table where message like 'quick brown f%';
```

#### multi_match

多重匹配：[传送门](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-multi-match-query.html)

> 一般用于关键字搜索

```js tab="Elasticsearch"
GET /_search
{
  "query": {
    "multi_match" : {
      "query": "this is", 
      "fields": ["subject", "message"]
    }
  }
}
```

```sql tab="SQL"
select * from table
where subject like '%this%'
    or subject like '%is%'
    or message like '%this%'
    or message like '%is%';
```

**其他用法**

- 模糊字段匹配：`"fields": ["subject", "*_message"]`
- `_score` 权重调整：`"fields" : [ "subject^3", "message" ]`
- 其他匹配类型，如： `best_fields(默认)`、 `phrase`、 `phrase_prefix` 等

!!! warning ""

    **警告：** 一次查询的字段数不得超过1024个

### Term 查询

#### term

通过倒排索引查找**确切**的值。 相当于 `=`，但不只是 `=`，更像是 PHP 的 `in_array` 的概念：[传送门](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-term-query.html) 

```js tab="Elasticsearch"
POST _search
{
  "query": {
    "term" : { "user" : "Kimchy" } 
  }
}
```

```sql tab="SQL"
select * from table where user = 'Kimchy';
```

!!! note "为什么 `term` 查询不符合我的文档？"

    **字符串**字段可以是 `text` 类型 （视为全文，如电子邮件正文），或 `keyword` 类型（视为确切的值，如电子邮件地址或邮政编码）。确切的值（如数字，日期和关键字）具有在添加到倒排索引的字段中指定的确切值，以便使它们可搜索。

    > 官方文档谷歌翻译...仅供参考

    **个人总结:** 日常应用中，`term` 查询相对更适合 `int` 类型的数据，如字符串可使用 `keyword` 类型。 而 Elasticsearch 默认在生成 `mapping` 映射时，会对字符串自动添加 `keyword` 类型。 如字段 `name`，可使用 `name.keyword`

!!! warning ""
    
    **数组说明：** 当文档的字段值为数组形式，如： `{"a": [1, 2]}`，`{"term": {"a": 1}}` 也能搜索到此文档，—— `in_array` 的理解。

#### terms

通过倒排索引中查找多个**确切**的值，相当于 `in`：[传送门](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-terms-query.html) 

```js tab="Elasticsearch"
GET /_search
{
    "query": {
        "terms" : { "user" : ["kimchy", "elasticsearch"]}
    }
}
```

```sql tab="SQL"
select * from table where user in ('Kimchy', 'elasticsearch');
```

#### range

范围区间查询，[传送门](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-range-query.html) 

```js tab="Elasticsearch"
GET _search
{
    "query": {
        "range" : {
            "age" : {
                "gte" : 10,
                "lte" : 20
            }
        }
    }
}
```

```sql tab="SQL"
select * from table where age >=10 and age <= 20;
```

参数说明

|参数|说明|
|----|----|
|`gte`|>=|
|`gt`|>|
|`lte`|<=|
|`lt`|<|

### 复合查询

#### bool

与其他查询构建语句进行组合的查询，构建语句包括：

|构建语句|说明
|----|----|
|`must`|**必须**出现在匹配的文档中的条件。有助于计算得分|
|`filter`|**必须**出现在匹配的文档中的条件。但是不同于 `must` 查询的分数将被忽略。忽略评分并考虑使用[子句](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/query-filter-context.html)进行**高速缓存**|
|`should`|应出现在匹配的文档中的条件，即满足即可。计算分值|
|`must_not`|不得出现在匹配的文档中的条件，不计算分值|

```js tab="Elasticsearch"
POST _search
{
  "query": {
    "bool" : {
      "must" : {
        "term" : { "user" : "kimchy" }
      },
      "filter": {
        "term" : { "tag" : "tech" }
      },
      "must_not" : {
        "range" : {
          "age" : { "gte" : 10, "lte" : 20 }
        }
      },
      "should" : [
        { "term" : { "tag" : "wow" } },
        { "term" : { "tag" : "elasticsearch" } }
      ]
    }
  }
}
```

```sql tab="SQL"
select * from table
where user = "kimchy"
    and tag = "tech"
    and (age < 10 or age > 20) -- not (age >= 10 and age <= 20)
    and (tag = "wow" or tag = "elasticsearch");
```

!!! info ""

    **个人理解：** `bool` 类似 `()`，而 `must(filter)` 类似 `and`；`should` 类似 `or`，`must_not` 类似 `not`。

    > **注：** `bool` 支持无限极嵌套，但 `bool` 下仅能编写以上四种构建语句。 


!!! info "补充：Elasticsearch会自动缓存经常使用的过滤器，以加快性能。"

    只要将查询子句传递给 `filter` 参数（例如查询中的 `filter`或 `must_not` 参数， `bool` 查询中的`filter` 参数 `constant_score` 或 `filter` 聚合）， 过滤器上下文就会生效。

## 实例讲解

> 本段培训使用，非培训人员可无视

??? question "查询 nginx 数据，条件为状态码为 301 和 302，结果只显示 `status,host,require_uri,geoip.ip` 字段，数量为 20 条的数据"

    ```json
    GET logstash-nginx_*/_search/
    {
      "query": {
        "terms": {
          "status": [301, 302]
        }
      },
      "_source": ["status", "host", "require_uri", "geoip.ip"],
      "size": 20
    }
    ```

    **内容要点：**
    
    - Kibana 简单使用：`Discover` 和 `Dev Tools`
    - `index` 索引支持通配符查询
    - `type` 可不指定查询

??? question "查询建案数据，户型匹配“三房”(`search.room_name含三房`)，且为预售屋或新成屋(`build_type=1 或 2`)，且在售状态(`sell_status = 1`)；排除关闭建案(`closed = 1`)；满足建案名中含“大”或“小”；按`status asc`和分值高到低排序。（其中三房和预售/新成屋、在售状态三个条件，不计算分值）"

    ```json
    GET build/_search
    {
      "query": {
        "bool": {
          "filter": [
            {"term": {"search.room_name.keyword": "三房"}},
            {"term": {"sell_status": 1}},
            {"bool": {
              "should": [
                {"term": {"build_type": 1}},
                {"term": {"build_type": 2}}
              ]
            }}
          ],
          "must_not": [
            {"term": {"closed": 1}}
          ],
          "should": [
            {"match": {"build_name": "大"}},
            {"match": {"build_name": "小"}}
          ]
        }
      },
      "_source": ["id", "build_name", "build_type", "search.room_name", "status", "closed", "sell_status"],
      "sort": [
        {"status": "asc"},
        {"_score": "desc"}
      ]
    }
    ```

    **内容要点：**
    
    - `bool` 使用，及嵌套使用
    - `must` 和 `filter` 区别（含分值排序）
    - `must_not` / `should` 理解
    - `term` 的理解：确切的值（`in_array`和`keyword`）

??? question "作业"

    待整理
