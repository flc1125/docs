# PHP 处理 JSON 数组或对象

客户端在关于 JSON 数组和 JSON 对象的处理和定义方面总是令人疑惑不已。尤其是由空对象和对象数组引起的问题。本节会展示一些 Elasticsearch JSON API 常见的数据格式，还会说明如何以 PHP 的语法来表达这些数据格式。

## 空对象

Elasticsearch API 在几个地方使用了空对象，这会对 PHP 造成影响。不像其它的语言，PHP 没有一个简便的符号来表示空对象，而许多开发者还不知道如何指定一个空对象。

设想在查询中增加 Highlight：

```js
{
    "query" : {
        "match" : {
            "content" : "quick brown fox"
        }
    },
    "highlight" : {
        "fields" : {
            "content" : {}<1>
        }
    }
}
```

- <1> 这个空对象便会引起问题

问题就在于 PHP 会自动把 `"content" : {}` 转换成 `"content" : []` ，在 Elasticsearch DSL 中这样的数据格式是非法的。我们需要告诉 PHP 那个空对象就是一个空对象而非空数组。为了在查询中定义空对象，你需要这样做：

```php
<?php
$params['body'] = array(
    'query' => array(
        'match' => array(
            'content' => 'quick brown fox'
        )
    ),
    'highlight' => array(
        'fields' => array(
            'content' => new \stdClass()<1>
        )
    )
);
$results = $client->search($params);
```

- <1> 使用 PHP 的 stdClass 对象来代表空对象，现在就可以解析为正确的 JSON 数据了。

通过使用一个 stdClass 对象，我们可以强制 `json_encode` 解析为空对象，而不是空数组。然而，这种冗余的写法是唯一解决 PHP 空对象的方法，没有简便的方法可以表示空对象。

## 对象数组

Elasticsearch DSL 的另一种常见的数据格式是对象数组。例如，假设在你的查询中增加排序：

```js
{
    "query" : {
        "match" : { "content" : "quick brown fox" }
    },
    "sort" : [ <1>
        {"time" : {"order" : "desc"}},
        {"popularity" : {"order" : "desc"}}
    ]
}
```

- <1> "sort" 内包含 JSON 对象数组。

这种形式很常见，但是在 PHP 中构建就稍微有些繁琐，因为这需要嵌套数组。用 PHP 写这种冗余的结构就让人读起来有点晦涩。为了构建对象数组，你要在数组中嵌套数组：

```php
<?php
$params['body'] = array(
    'query' => array(
        'match' => array(
            'content' => 'quick brown fox'
        )
    ),
    'sort' => array( <1>
        array('time' => array('order' => 'desc')), <2>
        array('popularity' => array('order' => 'desc')) <3>
    )
);
$results = $client->search($params);
```

- <1> 这里 encode 为 `"sort" : []`
- <2> 这里 encode 为 `{"time" : {"order" : "desc"}}`
- <3> 这里 encode 为 `{"popularity" : {"order" : "desc"}}`

如果你用的是 PHP5.4 及以上版本，我强烈要求你使用 `[]` 构建数组。这会让多维数组看起来易读些：

```php
<?php
$params['body'] = [
    'query' => [
        'match' => [
            'content' => 'quick brown fox'
        ]
    ],
    'sort' => [
        ['time' => ['order' => 'desc']],
        ['popularity' => ['order' => 'desc']]
    ]
];
$results = $client->search($params);
```

## 空对象数组

偶尔你会看到 DSL 需要上述两种数据格式。score 查询便是一个很好的例子，该查询有时需要一个对象数组，而有一些对象可能是一个空的 JSON 对象。

请看如下查询：

```js
{
   "query":{
      "function_score":{
         "functions":[
            {
               "random_score":{}
            }
         ],
         "boost_mode":"replace"
      }
   }
}
```

我们用下面的 PHP 代码来构建这个查询：

```php
<?php
$params['body'] = array(
    'query' => array(
        'function_score' => array(
            'functions' => array( <1>
                array( <2>
                    'random_score' => new \stdClass() <3>
                )
            )
        )
    )
);
$results = $client->search($params);
```

- <1> 这里 encode 为 `"functions" : []`
- <2> 这里 encode 为 `{ "random_score": {} }`
- <3> 这里 encode 为 `"random_score": {}`