# 概述

## 安装

```bash
composer require flc/laravel-elasticsearch
```

## 配置

```

```

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