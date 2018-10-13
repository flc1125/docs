# Elasticsearch 入门

## 概念理解

### index

### type

### document

### 分析器

## 增删改查

### 新增

### 更新

### 删除

### 查找

## 常用 DSL

!!! tip ""

    **Tips：** 以下会列出 Elasticsearch 方式和 SQL “等价”方式查询便于理解。但实际应用中，部分场景，数据结果，不一定完全等价。

### Match 全文查询

#### match

默认匹配：[传送门](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-query.html)
    
```json tab="Elasticsearch"
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

```json tab="Elasticsearch"
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

```json tab="Elasticsearch"
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

```json tab="Elasticsearch"
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

```json tab="Elasticsearch"
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

### 复合查询

### 调试

## 实例讲解

??? question "查询状态码：200和301"

    tests
    tests

## Elasticsearch - PHP

## Kibana 使用