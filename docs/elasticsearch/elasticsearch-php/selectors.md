# 选择器

连接池维持一份连接清单，它决定节点在什么时候从活节点转变为死节点（或死节点转变为活节点）。然而连接池选择连接对象时是没有逻辑的，这份工作属于 Selector 类。

选择器（selector）的工作是从连接数组中返回一个连接。和连接池一样，也有几种选择器可供选择。

## RoundRobinSelector（默认）

选择器通过轮询调度的方式来返回连接。例如在第一个请求中选择节点1，在第二请求中选择节点 2，以此类推。这确保集群中的节点平均负担流量。轮询调度是基于每个请求来执行的（例如，一个PHP脚本的所有请求轮流发送到不同的节点中）。

`RoundRobinSelector` 是默认选择器，但如果你想明确地配置该选择器，你可以这样做：

```php
<?php
$client = ClientBuilder::create()
            ->setSelector('\Elasticsearch\ConnectionPool\Selectors\RoundRobinSelector')
            ->build();
```

注意：要通过命名空间加类名的方法来指定选择器。

## StickyRoundRobinSelector

这个选择器具有“粘性”，它更喜欢重用同一个连接。例如，在第一个请求中选择节点1，选择器会重用节点1来发送随后的请求，直到节点请求失败。在节点1请求失败后，选择器会轮询至下一个可用节点，然后一直重用这个节点。

对许多 PHP 脚本来说，这是一个理想的策略。由于 PHP 脚本是无共享架构且会快速退出，为每个请求创建新连接通常是一种次优策略且会引起大量的开销。相反，在脚本运行期间“黏住”单个节点会更好。

这个选择器会默认会在初始化时把 hosts 随机打乱，但仍然保证集群中的节点平均负担流量。它动态地更改轮询方式，把轮询每个请求变成轮询每个脚本。

如果你使用 [Future 模式](future_mode.md) ，这种选择器的“粘性”行为就不理想了，因为所有并行的请求会发送到集群中的同一个节点而非多个节点。当使用 Future 模式时，默认的 `RoundRobinSelector` 选择器会更好。

如果你要使用该选择器，你要这样做：

```php
<?php
$client = ClientBuilder::create()
            ->setSelector('\Elasticsearch\ConnectionPool\Selectors\StickyRoundRobinSelector')
            ->build();
```

注意：要通过命名空间加类名的方法来指定选择器。

## RandomSelector

这种选择器仅仅返回一个随机的节点，不管节点是处于什么状态。这个选择器通常用做测试。

如果你要使用该选择器，你要这样做：

```php
<?php
$client = ClientBuilder::create()
            ->setSelector('\Elasticsearch\ConnectionPool\Selectors\RandomSelector')
            ->build();
```

注意：要通过命名空间加类名的方法来指定选择器。

## 自定义选择器

你可以实现自定义选择器。自定义选择器必须实现 `SelectorInterface` 接口。

```php
<?php
namespace MyProject\Selectors;

use Elasticsearch\Connections\ConnectionInterface;
use Elasticsearch\ConnectionPool\Selectors\SelectorInterface

class MyCustomSelector implements SelectorInterface
{

    /**
     * Selects the first connection
     *
     * @param array $connections Array of Connection objects
     *
     * @return ConnectionInterface
     */
    public function select($connections)
    {
        // code here
    }

}
```

然后你可以通过对象注入或命名空间实例化方式来使用自定义选择器：

```php
<?php
$mySelector = new MyCustomSelector();

$client = ClientBuilder::create()
            ->setSelector($mySelector)                             // object injection
            ->setSelector('\MyProject\Selectors\FirstSelector')    // or namespace
            ->build();
```