# 责任链模式（Chain Of Responsibilities）

## 1. 目的

建立一个对象链来按指定顺序处理调用。如果其中一个对象无法处理命令，它会委托这个调用给它的下一个对象来进行处理，以此类推。

## 2. 例子

- 日志框架，每个链元素自主决定如何处理日志消息。
- 垃圾邮件过滤器。
- 缓存：例如第一个对象是一个 `Memcached` 接口实例，如果 “丢失” 它会委托数据库接口处理这个调用。
- Yii 框架: `CFilterChain` 是一个控制器行为过滤器链。执行点会有链上的过滤器逐个传递，并且只有当所有的过滤器验证通过，这个行为最后才会被调用。

## 3. UML 图

![](https://lccdn.phphub.org/uploads/images/201803/19/1/788RLCJGxg.png)

## 4. 代码

你也可以在 [GitHub](https://github.com/domnikl/DesignPatternsPHP/tree/master/Behavioral/ChainOfResponsibilities) 上查看此代码

Handler.php

```php
<?php

namespace DesignPatterns\Behavioral\ChainOfResponsibilities;

use Psr\Http\Message\RequestInterface;
use Psr\Http\Message\ResponseInterface;

/**
 * 创建处理器抽象类 Handler 。
 */
abstract class Handler
{
    /**
     * @var Handler|null
     * 定义继承处理器
     */
    private $successor = null;

    /**
     * 输入集成处理器对象。
     */
    public function __construct(Handler $handler = null)
    {
        $this->successor = $handler;
    }

    /**
     * 通过使用模板方法模式这种方法可以确保每个子类不会忽略调用继
     * 承。
     *
     * @param RequestInterface $request
     * 定义处理请求方法。
     * 
     * @return string|null
     */
    final public function handle(RequestInterface $request)
    {
        $processed = $this->processing($request);

        if ($processed === null) {
            // 请求尚未被目前的处理器处理 => 传递到下一个处理器。
            if ($this->successor !== null) {
                $processed = $this->successor->handle($request);
            }
        }

        return $processed;
    }

    /**
     * 声明处理方法。
     */
    abstract protected function processing(RequestInterface $request);
}
```

Responsible/FastStorage.php

```php
<?php

namespace DesignPatterns\Behavioral\ChainOfResponsibilities\Responsible;

use DesignPatterns\Behavioral\ChainOfResponsibilities\Handler;
use Psr\Http\Message\RequestInterface;

/**
 * 创建 http 缓存处理类。
 */
class HttpInMemoryCacheHandler extends Handler
{
    /**
     * @var array
     */
    private $data;

    /**
     * @param array $data
     * 传入数据数组参数。
     * @param Handler|null $successor
     * 传入处理器类对象 $successor 。
     */
    public function __construct(array $data, Handler $successor = null)
    {
        parent::__construct($successor);

        $this->data = $data;
    }

    /**
     * @param RequestInterface $request
     * 传入请求类对象参数 $request 。
     * @return string|null
     * 
     * 返回缓存中对应路径存储的数据。
     */
    protected function processing(RequestInterface $request)
    {
        $key = sprintf(
            '%s?%s',
            $request->getUri()->getPath(),
            $request->getUri()->getQuery()
        );

        if ($request->getMethod() == 'GET' && isset($this->data[$key])) {
            return $this->data[$key];
        }

        return null;
    }
}
```

Responsible/SlowStorage.php

```php
<?php

namespace DesignPatterns\Behavioral\ChainOfResponsibilities\Responsible;

use DesignPatterns\Behavioral\ChainOfResponsibilities\Handler;
use Psr\Http\Message\RequestInterface;

/**
 * 创建数据库处理器。
 */
class SlowDatabaseHandler extends Handler
{
    /**
     * @param RequestInterface $request
     * 传入请求类对象 $request 。
     * 
     * @return string|null
     * 定义处理方法，下面应该是个数据库查询动作，但是简单化模拟，直接返回一个 'Hello World' 字符串作查询结果。
     */
    protected function processing(RequestInterface $request)
    {
        // 这是一个模拟输出， 在生产代码中你应该调用一个缓慢的 （相对于内存来说） 数据库查询结果。

        return 'Hello World!';
    }
}
```

## 5. 测试

Tests/ChainTest.php

```php
<?php

namespace DesignPatterns\Behavioral\ChainOfResponsibilities\Tests;

use DesignPatterns\Behavioral\ChainOfResponsibilities\Handler;
use DesignPatterns\Behavioral\ChainOfResponsibilities\Responsible\HttpInMemoryCacheHandler;
use DesignPatterns\Behavioral\ChainOfResponsibilities\Responsible\SlowDatabaseHandler;
use PHPUnit\Framework\TestCase;

/**
 * 创建一个自动化测试单元 ChainTest 。
 */
class ChainTest extends TestCase
{
    /**
     * @var Handler
     */
    private $chain;

    /**
     * 模拟设置缓存处理器的缓存数据。
     */
    protected function setUp()
    {
        $this->chain = new HttpInMemoryCacheHandler(
            ['/foo/bar?index=1' => 'Hello In Memory!'],
            new SlowDatabaseHandler()
        );
    }

    /**
     * 模拟从缓存中拉取数据。
     */
    public function testCanRequestKeyInFastStorage()
    {
        $uri = $this->createMock('Psr\Http\Message\UriInterface');
        $uri->method('getPath')->willReturn('/foo/bar');
        $uri->method('getQuery')->willReturn('index=1');

        $request = $this->createMock('Psr\Http\Message\RequestInterface');
        $request->method('getMethod')
            ->willReturn('GET');
        $request->method('getUri')->willReturn($uri);

        $this->assertEquals('Hello In Memory!', $this->chain->handle($request));
    }

    /**
     * 模拟从数据库中拉取数据。
     */
    public function testCanRequestKeyInSlowStorage()
    {
        $uri = $this->createMock('Psr\Http\Message\UriInterface');
        $uri->method('getPath')->willReturn('/foo/baz');
        $uri->method('getQuery')->willReturn('');

        $request = $this->createMock('Psr\Http\Message\RequestInterface');
        $request->method('getMethod')
            ->willReturn('GET');
        $request->method('getUri')->willReturn($uri);

        $this->assertEquals('Hello World!', $this->chain->handle($request));
    }
}
```

----

原文：

- https://laravel-china.org/docs/php-design-patterns/2018/ChainOfResponsibilities/1507