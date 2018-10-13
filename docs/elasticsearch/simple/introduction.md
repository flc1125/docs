# Elasticsearch 入门

## 概念理解

### `index`

### `type`

### `document`

### 分析器

## 增删改查

### 新增

### 更新

### 删除

### 查找

## 常用 DSL

!!! tip ""

    **Tips：** 以下会列出 Elasticsearch 方式和 SQL “等价”方式查询便于理解。但实际应用中，部分场景，数据结果，不一定完全等价。

### Match 查询

#### `match`

默认匹配：[传送门](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-query.html)
    
```bash tab="Elasticsearch"
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

#### `match_phrase`

短语匹配：[传送门](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-query-phrase.html)

```bash tab="Elasticsearch"
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

#### `match_phrase_prefix`

短语前缀匹配：[传送门](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-match-query-phrase-prefix.html)

> 一般用于搜索框：建议搜索

```bash tab="Elasticsearch"
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

#### `multi_match`

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

!!! warning ""

    **警告：** 一次查询的字段数不得超过1024个

### Term 查询

### 复合查询

## 实例讲解

??? question "查询状态码：200和301"

    tests
    tests

## Elasticsearch - PHP

## Kibana 使用