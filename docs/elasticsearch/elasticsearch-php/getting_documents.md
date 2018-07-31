# 获取文档

Elasticsearch 提供实时获取文档的方法。这意味着只要文档被索引且客户端收到消息确认后，你就可以立即在任何的分片中检索文档。Get 操作通过 `index/type/id` 方式请求一个文档信息：

```php
<?php
$params = [
    'index' => 'my_index',
    'type' => 'my_type',
    'id' => 'my_id'
];

// Get doc at /my_index/my_type/my_id
$response = $client->get($params);
```