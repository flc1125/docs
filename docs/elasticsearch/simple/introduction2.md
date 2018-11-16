# Elasticsearch 入门（二）

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