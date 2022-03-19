# PHP DSL 查修构造器扩展

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

##### 索引单文档

=== "PHP"

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

=== "Result"

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

!!! warning ""

    **注意：**

    1. 文档 ID 可忽略，如未指定ID，系统自动生成。
    1. 如指定文档 ID， 若文档存在，则全量覆盖；若不存在，则新增文档。

    > 因 Elasticsearch 分布式特性，尤其大数据方面，文档 ID 建议不写或自定义非连续的随机数。

##### 批量（bulk）索引文档

Elasticsearch 也支持批量（bulk）索引文档。

```php
<?php

for($i = 0; $i < 100; $i++) {
    $params['body'][] = [
        'index' => [
            '_index' => 'my_index',
            '_type' => 'my_type',
        ]
    ];

    $params['body'][] = [
        'my_field' => 'my_value',
        'second_field' => 'some more values'
    ];
}

$responses = $client->bulk($params);
```

#### 1.3.2. 更新文档

##### 部分更新

如果你要部分更新文档（如更改现存字段，或添加新字段），你可以在 body 参数中指定一个 doc 参数。这样 doc 参数内的字段会与现存字段进行合并。

```php
$params = [
    'index' => 'my_index',
    'type' => 'my_type',
    'id' => 'my_id',
    'body' => [
        'doc' => [
            'new_field' => 'abc'
        ]
    ]
];

$response = $client->update($params);
```

##### script 更新

有时你要执行一个脚本来进行更新操作，如对字段进行自增操作或添加新字段。为了执行一个脚本更新，你要提供脚本命令和一些参数：

```php
$params = [
    'index' => 'my_index',
    'type' => 'my_type',
    'id' => 'my_id',
    'body' => [
        'script' => 'ctx._source.counter += count',
        'params' => [
            'count' => 4
        ]
    ]
];

$response = $client->update($params);
```

#### 1.3.3. 获取文档

查询指定 ID 的数据

=== "PHP"

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

=== "Result"

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

#### 1.3.4. 搜索文档

=== "PHP"
    
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

=== "Result"

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

### 2.1. 安装&配置

[传送门](../laravel-elasticsearch/introduction.md)

### 2.2. 查询构造器

[传送门](../laravel-elasticsearch/builder.md)