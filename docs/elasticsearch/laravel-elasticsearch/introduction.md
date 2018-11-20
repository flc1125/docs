# 概述

## 开源地址

https://github.com/flc1125/laravel-elasticsearch

## 安装

```bash
composer require flc/laravel-elasticsearch
```

## 配置

**加入服务提供者**

在 `config/app.php` 文件下加入服务提供者：

```
'providers' => [

    ...

    Flc\Laravel\Elasticsearch\ElasticsearchServiceProvider::class,
]
```

**发布配置**

```bash
php artisan vendor:publish --provider="Flc\Laravel\Elasticsearch\ElasticsearchServiceProvider"
```

你可以通过 `config/elasticsearch.php` 文件中修改 Elasticsearch 的连接配置。

## 示例

```php
<?php

use Elasticsearch;

Elasticsearch::index('users')
    ->select('id', 'username', 'password', 'created_at', 'updated_at', 'status', 'deleted')
    ->whereTerm('status', 1)
    ->orWhereIn('deleted', [1, 2])
    ->whereNotExists('area')
    ->where(['status' => 1, 'closed' => 0])
    ->where(function ($query) {
        $query->where('status', '=', 1)
            ->where('closed', 1)
            ->where('username', 'like', '张三')
            ->where('username', 'match', '李四');
    })
    ->orderBy('id', 'desc')
    ->take(2)
    ->paginate(10);
```