# Future 模式

客户端提供 future 模式（或叫异步模式）。future 模式允许批量发送请求（并行发送到集群），这对于提高性能和生产力有极大帮助。

PHP 是单线程的脚本语言，然而 libcurl 的 multi interface 功能使得像 PHP 这种单线程的语言可以批量发送请求，从而获得并发性特征。批量请求是通过底层的多线程 libcurl 库并行的发送请求给 Elasticsearch，而返回给PHP的数据也是批量的。

在单线程环境下，执行 `n` 个请求的时间等于 `n` 个请求时间相加。在 multi interface 功能下，执行 `n` 个请求的时间等于最慢的一个请求时间。

除此以外，multi-interface 功能允许批量请求同时发送到不同的主机，这意味着 Elasticsearch-PHP 可以更高效地利用集群。

## 使用 Future 模式

使用这种模式相对简单，只是你要写多一点代码。为了开启 future 模式，在 client 选项中增加 `future` 参数，并设置值为 `'lazy'` ：

```php
<?php
$client = ClientBuilder::create()->build();

$params = [
    'index' => 'test',
    'type' => 'test',
    'id' => 1,
    'client' => [
        'future' => 'lazy'
    ]
];

$future = $client->get($params);
```

这里会返回一个 _future_ 对象，而不是真正的响应数据。future 对象是待处理对象，它看起来就像是个占位符。你可以把 future 对象当成是普通对象在代码中传递使用。当你需要响应数据时，你可以解析 future 对象。如果 future 对象已经被解析，可以立即使用响应数据。如果 future 对象还没被解析完，那么解析动作会阻塞 PHP 脚本的执行，直到解析完成。

在实际应用中，你可以通过设置 `future: lazy` 键值对构造一个请求队列，而返回的 future 对象直到解析完成，程序才会继续执行。无论什么时候，全部的请求都是以并行方式发送到集群，以异步方式返回给 curl。

这听起来好复杂，但由于RingPHP的 `FutureArray` 接口，这些操作则变得很简单。它让 future 对象看起来像是一个关联数组。例如：

```php
<?php
$client = ClientBuilder::create()->build();

$params = [
    'index' => 'test',
    'type' => 'test',
    'id' => 1,
    'client' => [
        'future' => 'lazy'
    ]
];

$future = $client->get($params);

$doc = $future['_source'];    // This call will block and force the future to resolve
```

就像通常的响应数据那样，future 对象可以用迭代关联数组的方式解析特定的值（轮流解析未解析的请求和值）。这样就可以写成如下形式：

```php
<?php
$client = ClientBuilder::create()->build();
$futures = [];

for ($i = 0; $i < 1000; $i++) {
    $params = [
        'index' => 'test',
        'type' => 'test',
        'id' => $i,
        'client' => [
            'future' => 'lazy'
        ]
    ];

    $futures[] = $client->get($params);     //queue up the request
}


foreach ($futures as $future) {
    // access future's values, causing resolution if necessary
    echo $future['_source'];
}
```

请求队列会并行执行，执行后赋值给 futures 数组。每批请求默认为 100 个。

如果你想强制解析 future 对象，但又不立刻获取响应数据。你可以用 future 对象的 `wait()` 方法来强制解析：

```php
<?php
$client = ClientBuilder::create()->build();
$futures = [];

for ($i = 0; $i < 1000; $i++) {
    $params = [
        'index' => 'test',
        'type' => 'test',
        'id' => $i,
        'client' => [
            'future' => 'lazy'
        ]
    ];

    $futures[] = $client->get($params);     //queue up the request
}

//wait() forces future resolution and will execute the underlying curl batch
$futures[999]->wait();
```

## 更改批量值

默认的批量值为 100 个，这意味着在客户端强制 future 对象解析前（执行 `curl_multi` 调用），队列可以容纳 100 个请求。批量值可以更改，取决于你的需求。批量值的调整是通过配置 HTTP handler 时设置 `max_handles` 参数来实现：

```php
<?php 
$handlerParams = [
    'max_handles' => 500
];

$defaultHandler = ClientBuilder::defaultHandler($handlerParams);

$client = ClientBuilder::create()
            ->setHandler($defaultHandler)
            ->build();
```  

上面的设置会更改批量发送数量为 500。注意：不管队列数量是否为最大批量值，强制解析 future 对象都会引起底层的 curl 执行批量请求操作。在如下的示例中，只有 499 个对象加入队列，但最后的 future 对象被解析会引起强制发送批量请求：

```php
<?php 
$handlerParams = [
    'max_handles' => 500
];

$defaultHandler = ClientBuilder::defaultHandler($handlerParams);

$client = ClientBuilder::create()
            ->setHandler($defaultHandler)
            ->build();

$futures = [];

for ($i = 0; $i < 499; $i++) {
    $params = [
        'index' => 'test',
        'type' => 'test',
        'id' => $i,
        'client' => [
            'future' => 'lazy'
        ]
    ];

    $futures[] = $client->get($params);     //queue up the request
}

// resolve the future, and therefore the underlying batch
$body = $future[499]['body'];
```

## 各种批量执行

队列里面允许存在各种请求。比如，你可以把 get 请求、index 请求和 search 请求放到队列里面：

```php
<?php 
$client = ClientBuilder::create()->build();
$futures = [];

$params = [
    'index' => 'test',
    'type' => 'test',
    'id' => 1,
    'client' => [
        'future' => 'lazy'
    ]
];

$futures['getRequest'] = $client->get($params);     // First request

$params = [
    'index' => 'test',
    'type' => 'test',
    'id' => 2,
    'body' => [
        'field' => 'value'
    ],
    'client' => [
        'future' => 'lazy'
    ]
];

$futures['indexRequest'] = $client->index($params);       // Second request

$params = [
    'index' => 'test',
    'type' => 'test',
    'body' => [
        'query' => [
            'match' => [
                'field' => 'value'
            ]
        ]
    ],
    'client' => [
        'future' => 'lazy'
    ]
];

$futures['searchRequest'] = $client->search($params);      // Third request

// Resolve futures...blocks until network call completes
$searchResults = $futures['searchRequest']['hits'];

// Should return immediately, since the previous future resolved the entire batch
$doc = $futures['getRequest']['_source'];
```

## 警告

使用 future 模式时需要注意几点。最大也是最明显的问题是：你要自己去解析 future 对象。这挺麻烦的，而且偶尔会引起一些意料不到的状况。

例如，假如你手动使用 `wait()` 方法解析，在需要重新构建 future 对象并解析的情况下，你也许要调用好几次 `wait()` 方法。这是因为每次重新构造 future 对象都会引起 future 对象的重新赋值（覆盖解析结果），所以每个 future 对象都要重新解析获取结果。

如果你使用 ArrayInterface 返回的结果（ `$response['hits']['hits']` ）则不用进行额外处理。然而 FutureArrayInterface 就要全面解析 future 对象才能使用响应数据。

另外一点是一些方法会失效。比如 exists 方法（ `$client->exists()` ,  `$client->indices()->exists` ,  `$client->indices->templateExists()` 等）在正常情况下会返回 true 或 false。

当使用 future 模式时，future 对象还未封装好，这代表客户端无法检测响应结果和返回 true 或 false。所以你会得到从 Elasticsearch 返回的未封装响应数据，而你不得不对这些数据进行处理。

这些注意事项也适用于 `ping()` 方法。