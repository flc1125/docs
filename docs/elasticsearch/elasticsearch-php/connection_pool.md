# 连接池

连接池是客户端内的一个对象，主要是维持现有节点的连接。理论上来讲，节点只有死节点与活节点。

然而在现实世界中，事情绝不会这么明确。有时候节点是处在 _“可能挂了但还未确认”_ 、 _“连接超时但未知原因”_ 或 _“最近挂过但现在可用”_ 的灰色地带中。而连接池的工作就是管理这些无规则的连接，并为客户端提供最稳定的连接状态。

如果一个连接池找不到一个活节点来发送查询，那么就会返回一个 `NoNodesAvailableException` 异常给客户端。这里跟最大重连次数（retry）有所不同。假如有这么一个例子：你的集群中可能有 10 个节点。你发送一个请求，其中有 9 个节点因为连接超时而请求失败。而第 10 个节点发送请求成功并成功执行请求。在上述例子中，前 9 个节点会被标记为死节点（连接池处于使用状态才会被标记），且它们的“死亡”定时器会启动生效。

当要发送下一个请求时，节点1-9是被标记为死节点，所以请求会跳过这些节点。请求只会发送到唯一的活节点 10 中，而假如发送到这个节点也失败了，那么就会返回 `NoNodesAvailableException` 。你会留意到这里的发送次数比重连次数（retries）的值要少，因为重连次数只适用于活节点。在这种情况下，只有一个节点是活节点，请求失败后就会返回 `NoNodesAvailableException` 。

这里有几种连接池可供选择：

## staticNoPingConnectionPool（默认）

连接池维持一个静态的 hosts 清单，这些 hosts 在客户端初始化时都被假定为活节点。如果一个节点处理请求失败，那么该节点会被标记为死节点并持续 60 秒，而请求会发送到下一个节点。60 秒过后，节点则会再生并加入请求轮询中。每增加一次请求失败次数都会导致死亡时间以指数级别增长。

请求成功一次后会重置 "failed ping timeout" 计数器。

如果你想明确的设置连接池为 `StaticNoPingConnectionPool` ，你可能要在ClientBuilder对象中使用 `setConnectionPool()` 方法：

```php
<?php
$client = ClientBuilder::create()
            ->setConnectionPool('\Elasticsearch\ConnectionPool\StaticNoPingConnectionPool', [])
            ->build();
```

注意：要通过命名空间加类名的方法来指定连接池。

## StaticConnectionPool

`StaticConnectionPool` 除了要在使用前 ping 节点来确定是否为活节点，其它的特性与 `StaticNoPingConnectionPool` 一致。这可能对于执行时间较长的脚本比较有用，但这往往会增加额外开销，因为对一般的PHP脚本来说这是不必要的。

使用 `StaticConnectionPool` 的方法：

```php
<?php
$client = ClientBuilder::create()
            ->setConnectionPool('\Elasticsearch\ConnectionPool\StaticConnectionPool', [])
            ->build();
```

注意：要通过命名空间加类名的方法来指定连接池。

## SimpleConnectionPool

`SimpleConnectionPool` 仅仅返回选择器（Selector）指定的下个节点信息，它不监测节点的“生死状态”。不管节点是活节点还是死节点，这种连接池都会返回节点信息给客户端。它仅仅是个简单的静态 host 连接池。

`SimpleConnectionPool` 不建议常规使用，但是它是个有用的调试工具。

使用 `SimpleConnectionPool` 的方法：

```php
<?php
$client = ClientBuilder::create()
            ->setConnectionPool('\Elasticsearch\ConnectionPool\SimpleConnectionPool', [])
            ->build();
```

注意：要通过命名空间加类名的方法来指定连接池。

## SniffingConnectionPool

`SniffingConnectionPool` 与前面的两个静态连接池有所不同，它是动态的。用户提供 hosts 种子，而客户端则会嗅探这些 hosts 并发现集群的其余节点。 `SniffingConnectionPool` 通过 Cluster State API 来实现嗅探。当集群添加新节点或删除节点，客户端会更新连接池的活跃连接。

使用 `SniffingConnectionPool` 的方法：

```php
<?php
$client = ClientBuilder::create()
            ->setConnectionPool('\Elasticsearch\ConnectionPool\SniffingConnectionPool', [])
            ->build();
```

注意：要通过命名空间加类名的方法来指定连接池。

## 自定义连接池

如果你要是实现自定义连接池，你的类则必须实现 `ConnectionPoolInterface` 接口：

```php
<?php
class MyCustomConnectionPool implements ConnectionPoolInterface
{

    /**
     * @param bool $force
     *
     * @return ConnectionInterface
     */
    public function nextConnection($force = false)
    {
        // code here
    }

    /**
     * @return void
     */
    public function scheduleCheck()
    {
        // code here
    }
}
```

然后你要实例化自定义的连接池并注入到 ClientBuilder：

```php
<?php
$myConnectionPool = new MyCustomConnectionPool();

$client = ClientBuilder::create()
            ->setConnectionPool($myConnectionPool, [])
            ->build();
```

如果你的连接池只有较小的变更，你可以考虑扩展 `AbstractConnectionPool` ，它提供一些具体的助手方法。如果你不选择这种做法，你就要确保连接池拥有兼容的构造方法（因为在接口中没有定义好）：

```php
<?php
class MyCustomConnectionPool extends AbstractConnectionPool implements ConnectionPoolInterface
{

    public function __construct($connections, SelectorInterface $selector, ConnectionFactory $factory, $connectionPoolParams)
    {
        parent::__construct($connections, $selector, $factory, $connectionPoolParams);
    }

    /**
     * @param bool $force
     *
     * @return ConnectionInterface
     */
    public function nextConnection($force = false)
    {
        // code here
    }

    /**
     * @return void
     */
    public function scheduleCheck()
    {
        // code here
    }
}
```

假如你的构造方法与 `AbstractConnectionPool` 的构造方法相同，你可以用对象注入或命名空间实例化来设置连接池：

```php
<?php
$myConnectionPool = new MyCustomConnectionPool();

$client = ClientBuilder::create()
            ->setConnectionPool($myConnectionPool, [])                                      // object injection
            ->setConnectionPool('/MyProject/ConnectionPools/MyCustomConnectionPool', [])    // or namespace
            ->build();
```

## 选择什么连接池？PHP 和连接池的关系

初看觉得 `sniffingConnectionPool` 似乎比较高级。对许多语言来说当然如此。但是 PHP 则有些不同。

因为 PHP 是无共享架构（share-nothing architecture），php 脚本实例化后无法维持一个连接池。这意味着每个脚本在重新执行时都要负责创建、维持和销毁连接。

嗅探是相对轻量的操作（调用一次API到 `/_cluster/state` ，然后 ping 每个节点），但是对于某些 PHP 程序来说，这可能是一笔不可忽视的开销。一般的 PHP 脚本可能会加载客户端，执行一些请求然后关闭。想象一下这个脚本每秒调用 1000 次： `SniffingConnectionPool` 会每秒执行嗅探和 ping 所有节点 1000 次。嗅探程序则会增加大量的开销。

在实际中，如果你的脚本只是执行一些请求，用嗅探就太粗暴了。嗅探对于常驻进程来说往往更加有用。

基于上述原因，默认连接池才设置为当前的 `staticNoPingConnectionPool` 。当然你可以更改默认连接池，但我们强烈建议你进行测试并确保连接池对于性能没有产生不良影响。