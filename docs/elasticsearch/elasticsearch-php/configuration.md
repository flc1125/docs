# 配置

几乎所有应用（译者注：如 mysql、redis 等）的客户端都可以配置。大多数用户只需配置一些参数来满足他们的需求，但是也有可能需要修改大量的内核代码来满足需求。

在客户端对象实例化前就应该通过 ClientBuilder 对象来完成自定义配置。我们会概述一下所有的配置参数，并且展示一些代码示例。

## Inline Host 配置法

最常见的配置是告诉客户端有关集群的信息：有多少个节点，节点的ip地址和端口号。如果没有指定主机名，客户端会连接 `localhost:9200` 。

利用 `ClientBuilder` 的 `setHosts()` 方法可以改变客户端的默认连接方式。 `setHosts()` 方法接收一个一维数组，数组里面每个值都代表集群里面的一个节点信息。值的格式多种多样，主要看你的需求：

```php
<?php
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

注意 `ClientBuilder` 对象允许链式操作。当然也可以分别调用上述的方法：

```php
<?php
$hosts = [
    '192.168.1.1:9200',         // IP + Port
    '192.168.1.2',              // Just IP
    'mydomain.server.com:9201', // Domain + Port
    'mydomain2.server.com',     // Just Domain
    'https://localhost',        // SSL to localhost
    'https://192.168.1.3:9200'  // SSL to IP + Port
];
$clientBuilder = ClientBuilder::create();   // Instantiate a new ClientBuilder
$clientBuilder->setHosts($hosts);           // Set the hosts
$client = $clientBuilder->build();          // Build the client object
```

## Extended Host 配置法

客户端也支持 Extended Host 配置语法。Inline Host 配置法依赖 PHP 的 `filter_var()` 函数和 `parse_url()` 函数来验证和提取一个 URL 的各个部分。然而，这些 php 函数在一些特定的场景下会出错。例如， `filter_var()` 函数不接收有下划线的 URL。同样，如果 Basic Auth 的密码含有特定字符（如#、?），那么 `parse_url()` 函数会报错。

因而客户端也支持 Extended Host 配置语法，从而使客户端实例化更加可控：

```php
<?php
$hosts = [
    // This is effectively equal to: "https://username:password!#$?*abc@foo.com:9200/"
    [
        'host' => 'foo.com',
        'port' => '9200',
        'scheme' => 'https',
        'user' => 'username',
        'pass' => 'password!#$?*abc'
    ],

    // This is equal to "http://localhost:9200/"
    [
        'host' => 'localhost',    // Only host is required
    ]
];
$client = ClientBuilder::create()           // Instantiate a new ClientBuilder
                    ->setHosts($hosts)      // Set the hosts
                    ->build();              // Build the client object
```

每个节点只需要配置 `host` 参数。如果其它参数不指定，那么默认的端口是 `9200` ，默认的 scheme 是 `http` 。

## 认证与加密

想了解 HTTP 认证和 SSL 加密的内容，请查看[认证与加密](security.md)。

## 设置重连次数

在一个集群中，如果操作抛出如下异常：connection refusal, connection timeout, DNS lookup timeout 等等（不包括4xx和5xx），客户端便会重连。客户端默认重连 `n` （n=节点数）次。

如果你不想重连，或者想更改重连次数。你可以使用 `setRetries()` 方法：

```php
<?php
$client = ClientBuilder::create()
                    ->setRetries(2)
                    ->build();
```

假如客户端重连次数超过设定值，便会抛出最后接收到的异常。例如，如果你有 10 个节点，设置 `setRetries(5)` ，客户端便会最多发送 5 次连接命令。如果 5 个节点返回的结果都是 connection timeout，那么客户端会抛出 `OperationTimeoutException` 。由于连接池处于使用状态，这些节点也可能会被标记为死节点。

为了识别是否为重连异常，抛出的异常会包含一个 `MaxRetriesException` 。例如，你可以在 catch 内使用 `getPrevious()` 来捕获一个特定的 curl 异常，以便查看是否包含 `MaxRetriesException` 。

```php
<?php
$client = Elasticsearch\ClientBuilder::create()
    ->setHosts(["localhost:1"])
    ->setRetries(0)
    ->build();

try {
    $client->search($searchParams);
} catch (Elasticsearch\Common\Exceptions\Curl\CouldNotConnectToHost $e) {
    $previous = $e->getPrevious();
    if ($previous instanceof 'Elasticsearch\Common\Exceptions\MaxRetriesException') {
        echo "Max retries!";
    }
}
```

由于所有 curl 抛出的异常（`CouldNotConnectToHost`, `CouldNotResolveHostException`, `OperationTimeoutException`）都继承 `TransportException` 。这样你就能够用 `TransportException` 来替代如上3种异常：

```php
<?php
$client = Elasticsearch\ClientBuilder::create()
    ->setHosts(["localhost:1"])
    ->setRetries(0)
    ->build();

try {
    $client->search($searchParams);
} catch (Elasticsearch\Common\Exceptions\TransportException $e) {
    $previous = $e->getPrevious();
    if ($previous instanceof 'Elasticsearch\Common\Exceptions\MaxRetriesException') {
        echo "Max retries!";
    }
}
```

## 开启日志

Elasticsearch-PHP 支持日志记录，但由于性能原因，所以默认没有开启。如果你希望开启日志，你就要选择一个日志记录工具并安装它，然后在客户端中开启日志。推荐使用 https://github.com/Seldaek/monolog[Monolog]，不过任何实现 PSR/Log 接口的日志记录工具都可以使用。

你会发现在安装 elasticsearch-php 时会建议安装 Monolog。为了使用 Monolog，请把它加入 `composer.json` ：

```json
{
    "require": {
        ...
        "elasticsearch/elasticsearch" : "~6.0",
        "monolog/monolog": "~1.0"
    }
}
```

然后用 composer 更新：

```sh
php composer.phar update
```

```php
<?php
一旦安装好 Monolog（或其他日志记录工具），你就要创建一个日志对象并且注入到客户端中。 `ClientBuilder` 对象有一个静态方法来构建一个通用的 Monolog-based 日志对象。你只需要提供存放日志路径就行：

$logger = ClientBuilder::defaultLogger('path/to/your.log');

$client = ClientBuilder::create()       // Instantiate a new ClientBuilder
            ->setLogger($logger)        // Set the logger with a default logger
            ->build();                  // Build the client object
```

你也可以指定记录的日志级别：

```php
<?php
// set severity with second parameter
$logger = ClientBuilder::defaultLogger('/path/to/logs/', Logger::INFO);

$client = ClientBuilder::create()       // Instantiate a new ClientBuilder
            ->setLogger($logger)        // Set the logger with a default logger
            ->build();                  // Build the client object
```

`defaultLogger()` 方法只是一个辅助方法，不要求你使用它。你可以自己创建日志对象，然后注入：

```php
<?php
use Monolog\Logger;
use Monolog\Handler\StreamHandler;

$logger = new Logger('name');
$logger->pushHandler(new StreamHandler('path/to/your.log', Logger::WARNING));

$client = ClientBuilder::create()       // Instantiate a new ClientBuilder
            ->setLogger($logger)        // Set your custom logger
            ->build();                  // Build the client object
```

## 配置 HTTP Handler

Elasticsearch-PHP 使用的是可替代的 HTTP 传输层——[RingPHP](https://github.com/guzzle/RingPHP/)。这允许客户端构建一个普通的 HTTP 请求，然后通过传输层发送出去。真正的请求细节隐藏在客户端内，并且这是模块化的，因此你可以根据你的需求来选择 HTTP handlers。

客户端使用的默认 handler 是结合型 handler（combination handler）。当使用同步模式，handler 会使用 `CurlHandler` 来一个一个地发送 curl 请求。这种方式对于单一请求（single requests）来说特别迅速。当异步（future）模式开启，handler 就转换成使用 `CurlMultiHandler` ， `CurlMultiHandler` 以 curl_multi 方式来发送请求。这样会消耗更多性能，但是允许批量 HTTP 请求并行执行。

你可以从以下一些助手函数中选择一个来配置 HTTP handler，或者你也可以自定义 HTTP handler：

```php
<?php
$defaultHandler = ClientBuilder::defaultHandler();
$singleHandler  = ClientBuilder::singleHandler();
$multiHandler   = ClientBuilder::multiHandler();
$customHandler  = new MyCustomHandler();

$client = ClientBuilder::create()
            ->setHandler($defaultHandler)
            ->build();
```

想要了解自定义 Ring handler 的细节，请查看 [RingPHP文档](http://ringphp.readthedocs.io/en/latest/)。

在所有的情况下都推荐使用默认的 handler。这不仅可以以同步模式快速发送请求，而且也保留了异步模式来实现并行请求。 如果你觉得你永远不会用到 future 模式，你可以考虑用 `singleHandler` ，这样会间接节省一些性能。

## 设置连接池

客户端会维持一个连接池，连接池内每个连接代表集群的一个节点。这里有好几种连接池可供使用，每个的行为都有些细微差距。连接池可通过 `setConnectionPool()` 来配置：

```php
<?php
$connectionPool = '\Elasticsearch\ConnectionPool\StaticNoPingConnectionPool';
$client = ClientBuilder::create()
            ->setConnectionPool($connectionPool)
            ->build();
```

更多细节请查询 [连接池配置](connection_pool.md)。

## 设置选择器（Selector）

连接池是用来管理集群的连接，但是选择器则是用来确定下一个 API 请求要用哪个连接。这里有几个选择器可供选择。选择器可通过 `setSelector()` 方法来更改：

```php
<?php
$selector = '\Elasticsearch\ConnectionPool\Selectors\StickyRoundRobinSelector';
$client = ClientBuilder::create()
            ->setSelector($selector)
            ->build();
```

更多细节请查询 [选择器配置](selectors.md)。

## 设置序列化器（Serializer）

客户端的请求数据是关联数组，但是 Elasticsearch 接受 JSON 数据。序列化器是指把 PHP 数组序列化为 JSON 数据。当然 Elasticsearch 返回的 JSON 数据也会反序列化为 PHP 数组。这看起来有些繁琐，但把序列化器模块化对于处理一些极端案例有莫大帮助。

大部分人不会更改默认的序列化器（ `SmartSerializer` ），但你真的想改变，那可以通过 `setSerializer()` 方法：

```php
<?php
$serializer = '\Elasticsearch\Serializers\SmartSerializer';
$client = ClientBuilder::create()
            ->setSerializer($serializer)
            ->build();
```

更多细节请查询 [序列化器配置](serializers.md)。

## 设置自定义 ConnectionFactory

当连接池发送请求时，ConnectionFactory 就会实例化连接对象。一个连接对象代表一个节点。因为 handler（通过RingPHP）才是真正的执行网络请求，那么连接对象的主要工作就是维持连接：节点是活节点吗？ping 的通吗？host 和端口是什么？

很少会去自定义 ConnectionFactory，但是如果你想做，那么你要提供一个完整的 ConnectionFactory 对象作为 `setConnectionFactory()` 方法的参数。这个自定义对象需要实现 ConnectionFactoryInterface 接口。

```php
<?php
class MyConnectionFactory implements ConnectionFactoryInterface
{

    public function __construct($handler, array $connectionParams,
                                SerializerInterface $serializer,
                                LoggerInterface $logger,
                                LoggerInterface $tracer)
    {
       // Code here
    }


    /**
     * @param $hostDetails
     *
     * @return ConnectionInterface
     */
    public function create($hostDetails)
    {
        // Code here...must return a Connection object
    }
}


$connectionFactory = new MyConnectionFactory(
    $handler,
    $connectionParams,
    $serializer,
    $logger,
    $tracer
);

$client = ClientBuilder::create()
            ->setConnectionFactory($connectionFactory);
            ->build();
```

如上所述，如果你想注入自定义的 ConnectionFactory，你自己就要负责写对它。自定义 ConnectionFactory 需要用到 HTTP handler，序列化器，日志和追踪。

## 设置 Endpoint 闭包

客户端使用 Endpoint 闭包来发送 API 请求到 Elasticsearch 的 Endpoint 对象。一个命名空间对象会通过闭包构建一个新的 Endpoint，这个意味着如果你想扩展 API 的 Endpoint，你可以很方便的做到。

例如，我们可以新增一个 endpoint：

```php
<?php
$transport = $this->transport;
$serializer = $this->serializer;

$newEndpoint = function ($class) use ($transport, $serializer) {
    if ($class == 'SuperSearch') {
        return new MyProject\SuperSearch($transport);
    } else {
        // Default handler
        $fullPath = '\\Elasticsearch\\Endpoints\\' . $class;
        if ($class === 'Bulk' || $class === 'Msearch' || $class === 'MPercolate') {
            return new $fullPath($transport, $serializer);
        } else {
            return new $fullPath($transport);
        }
    }
};

$client = ClientBuilder::create()
            ->setEndpoint($newEndpoint)
            ->build();
```

很明显，如果你这样做的话，那么你就要负责对现存的 Endpoint 进行维护，以确保所有的方法都能正常运行。同时你也要确保端口和序列化都写入每个 Endpoint。

## 从 hash 配置中创建客户端

为了更加容易的创建客户端，所有的配置都可以用 hash 形式来替代单一配置方法。这种配置方法可以通过静态方法 `ClientBuilder::FromConfig()` 来完成，它接收一个数组，返回一个配置好的客户端。

数组的键名对应方法名（如 retries 对应 setRetries() 方法）：

```php
<?php
$params = [
    'hosts' => [
        'localhost:9200'
    ],
    'retries' => 2,
    'handler' => ClientBuilder::singleHandler()
];
$client = ClientBuilder::fromConfig($params);
```

为了帮助用户找出潜在的问题，未知参数会抛出异常。如果你不想要抛出异常，你可以在 fromConfig() 中设置 $quiet = true 来关闭异常：

```php
<?php
$params = [
    'hosts' => [
        'localhost:9200'
    ],
    'retries' => 2,
    'imNotReal' => 5
];

// Set $quiet to true to ignore the unknown `imNotReal` key
$client = ClientBuilder::fromConfig($params, true);
```