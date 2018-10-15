# Elasticsearch 入门

## 简介

### 什么是 Elasticsearch

### 应用场景

### 哪些企业在用


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

    **官方在 6.0.0 中弃用（非删除）。 请参考 [删除映射类型](删除映射类型)**。 为兼容后续版本，**官方推荐使用 `_doc` 作为类型名**

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

### From / Size ： [传送门](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/search-uri-request.html)

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

!!! warn ""
    
    **`from` 默认为 0，`size` 默认为 10。 这点与 SQL 不同。**

    > 请注意，`from + size` 不能超过索引设置 [`index.max_result_window`](https://www.elastic.co/guide/en/elasticsearch/reference/6.4/index-modules.html), 该值默认为10,000。

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

通过倒排索引查找**确切**的值。 相当于 `=`，但不只是 `=`：[传送门](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-term-query.html) 

> 需要整理数组的情况，是否可查询***************************

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
|`filter`|**必须**出现在匹配的文档中的条件。但是不同于 `must` 查询的分数将被忽略。忽略评分并考虑使用子句进行**高速缓存**|
|`should`|应出现在匹配的文档中的条件，即满足即可|
|`must_not`|不得出现在匹配的文档中的条件|

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


### 调试

## 实例讲解

??? question "查询状态码：200和301"

    tests
    tests

## Elasticsearch - PHP

## Kibana 使用