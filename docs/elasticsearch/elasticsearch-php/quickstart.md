# 快速开始编辑

这一节会概述一下客户端以及客户端的一些主要方法的使用规则。

## 安装

- 在 composer.json 文件中引入 elasticsearch-php：

    ```json
    {
        "require": {
            "elasticsearch/elasticsearch": "~6.0"
        }
    }
    ```

- 用 composer 安装客户端：

    ```bash
    curl -s http://getcomposer.org/installer | php
    php composer.phar install --no-dev
    ```

- 在项目中引入自动加载文件（如果还没引入），并且实例化一个客户端：

    ```php
    <?php
    require 'vendor/autoload.php';

    use Elasticsearch\ClientBuilder;

    $client = ClientBuilder::create()->build();
    ```

## 索引一个文档

在 elasticsearch-php 中，几乎一切操作都是用关联数组来配置。REST 路径（endpoint）、文档和可选参数都是用关联数组来配置。

为了索引一个文档，我们要指定4部分信息：`index`，`type`，`id` 和一个 `body`。构建一个键值对的关联数组就可以完成上面的内容。body 的键值对格式与文档的数据保持一致性。（译者注：如 `["testField" ⇒ "abc"]` 在文档中则为 `{"testField" : "abc"}`）：

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

收到的响应数据表明，你指定的索引中已经创建好了文档。响应数据是一个关联数组，里面的内容是 Elasticsearch 返回的decoded JSON 数据：

```
Array
(
    [_index] => my_index
    [_type] => my_type
    [_id] => my_id
    [_version] => 1
    [result] => created
    [_shards] => Array
        (
            [total] => 2
            [successful] => 1
            [failed] => 0
        )

    [_seq_no] => 0
    [_primary_term] => 1
)
```

## 获取一个文档

现在获取刚才索引的文档：

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

响应数据包含一些元数据（如 index，type 等）和 `_source` 属性， 这是你发送给 Elasticsearch 的原始文档数据。

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

## 搜索一个文档

搜索是 elasticsearch 的一大特色，所以我们试一下执行一个搜索。我们准备用 Match 查询来作为示范：

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

这个响应数据与前面例子的响应数据有所不同。这里有一些元数据（如 `took`, `timed_out` 等）和一个 `hits` 的数组，这代表了你的搜索结果。而 `hits` 内部也有一个 `hits` 数组，内部的 `hits` 包含特定的搜索结果：

```
Array
(
    [took] => 16
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
            [total] => 1
            [max_score] => 0.2876821
            [hits] => Array
                (
                    [0] => Array
                        (
                            [_index] => my_index
                            [_type] => my_type
                            [_id] => my_id
                            [_score] => 0.2876821
                            [_source] => Array
                                (
                                    [testField] => abc
                                )
                        )
                )
        )
)
```

## 删除一个文档

好了，现在我们看一下如何把之前添加的文档删除掉：

```php
<?php
$params = [
    'index' => 'my_index',
    'type' => 'my_type',
    'id' => 'my_id'
];

$response = $client->delete($params);
print_r($response);
```

你会注意到删除文档的语法与获取文档的语法是一样的。唯一不同的是 `delete` 方法替代了 `get` 方法。下面响应数据代表文档已被删除：

```
Array
(
    [_index] => my_index
    [_type] => my_type
    [_id] => my_id
    [_version] => 2
    [result] => deleted
    [_shards] => Array
        (
            [total] => 2
            [successful] => 1
            [failed] => 0
        )

    [_seq_no] => 1
    [_primary_term] => 1
)
```

## 删除一个索引

由于 elasticsearch 的动态特性，我们创建的第一个文档会自动创建一个索引，同时也会把 settings 里面的参数设定为默认参数。由于我们在后面要指定特定的 settings，所以现在要删除掉这个索引：

```php
<?php
$deleteParams = [
    'index' => 'my_index'
];
$response = $client->indices()->delete($deleteParams);
print_r($response);
```

响应数据是：

```
Array
(
    [acknowledged] => 1
)
```

## 创建一个索引

由于数据已被清空，我们可以重新开始了，现在要添加一个索引，同时要进行自定义 settings：

```php
<?php
$params = [
    'index' => 'my_index',
    'body' => [
        'settings' => [
            'number_of_shards' => 2,
            'number_of_replicas' => 0
        ]
    ]
];

$response = $client->indices()->create($params);
print_r($response);
```

Elasticsearch会创建一个索引，并配置你指定的参数值，然后返回一个消息确认：

```
Array
(
    [acknowledged] => 1
    [shards_acknowledged] => 1
    [index] => my_index
)
```

## 本节结语

这里只是概述了一下客户端以及它的语法。如果你很熟悉 elasticsearch，你会注意到这些方法的命名跟 REST 路径（endpoint）是一样的。

你也注意到了客户端的参数配置从某种程度上讲也是方便你的IDE易于搜索。`$client` 对象下的所有核心方法（索引，搜索，获取等）都是可用的。索引管理和集群管理分别在 `$client->indices()` 和 `$client->cluster()` 中。

请查询文档的其余内容以便知道整个客户端的运作机制。