# 服务定位器模式（Service Locator）

**服务定位器模式被认为是一种反面模式！**

服务定位器模式被一些人认为是一种反面模式。它违反了依赖倒置原则。该模式隐藏类的依赖，而不是暴露依赖（如果暴露可通过依赖注入的方式注入依赖）。当某项服务的依赖发生变化时，使用该服务的类的功能将面临被破坏的风险，最终导致系统难以维护。

## 1. 目的

服务定位器模式能够降低代码的耦合度，以便获得可测试、可维护和可扩展的代码。DI 模式和服务定位器模式是 IOC 模式的一种实现。

## 2. 用法

使用 `ServiceLocator` ，你可以为给定的 `interface` 注册一个服务。通过使用这个 `interface`，你不需要知道该服务的实现细节，就可以获取并在你应用中使用该服务。你可以在引导程序中配置和注入服务定位器对象。

## 3. 例子

- `Zend Framework2` 使用服务定位器创建和共享框架中使用的服务（`EventManager`，`ModuleManager`，以及由模块提供的用户自定义服务等）

## 4. UML 图

![](https://lccdn.phphub.org/uploads/images/201803/19/1/2pn0Utic36.png)

## 5. 代码

你可以在 [GitHub](https://github.com/domnikl/DesignPatternsPHP/tree/master/More/ServiceLocator) 上找到这些代码

ServiceLocator.php

```php
<?php

namespace DesignPatterns\More\ServiceLocator;

class ServiceLocator
{
    /**
     * @var array
     */
    private $services = [];

    /**
     * @var array
     */
    private $instantiated = [];

    /**
     * @var array
     */
    private $shared = [];

    /**
     * 相比在这里提供一个类，你也可以为接口存储一个服务。
     *
     * @param string $class
     * @param object $service
     * @param bool $share
     */
    public function addInstance(string $class, $service, bool $share = true)
    {
        $this->services[$class] = $service;
        $this->instantiated[$class] = $service;
        $this->shared[$class] = $share;
    }

    /**
     * 相比在这里提供一个类，你也可以为接口存储一个服务。
     *
     * @param string $class
     * @param array $params
     * @param bool $share
     */
    public function addClass(string $class, array $params, bool $share = true)
    {
        $this->services[$class] = $params;
        $this->shared[$class] = $share;
    }

    public function has(string $interface): bool
    {
    }

    /**
     * @param string $class
     *
     * @return object
     */
    public function get(string $class)
    {
        if (isset($this->instantiated[$class]) && $this->shared[$class]) {
            return $this->instantiated[$class];
        }

        $args = $this->services[$class];

        switch (count($args)) {
            case 0:
                $object = new $class();
                break;
            case 1:
                $object = new $class($args[0]);
                break;
            case 2:
                $object = new $class($args[0], $args[1]);
                break;
            case 3:
                $object = new $class($args[0], $args[1], $args[2]);
                break;
            default:
                throw new \OutOfRangeException('Too many arguments given');
        }

        if ($this->shared[$class]) {
            $this->instantiated[$class] = $object;
        }

        return $object;
    }
}
```

LogService.php

```php
<?php

namespace DesignPatterns\More\ServiceLocator;

class LogService
{
}
```

## 6. 测试

Tests/ServiceLocatorTest.php

```php
<?php

namespace DesignPatterns\More\ServiceLocator\Tests;

use DesignPatterns\More\ServiceLocator\LogService;
use DesignPatterns\More\ServiceLocator\ServiceLocator;
use PHPUnit\Framework\TestCase;

class ServiceLocatorTest extends TestCase
{
    /**
     * @var ServiceLocator
     */
    private $serviceLocator;

    public function setUp()
    {
        $this->serviceLocator = new ServiceLocator();
    }

    public function testHasServices()
    {
        $this->serviceLocator->addInstance(LogService::class, new LogService());

        $this->assertTrue($this->serviceLocator->has(LogService::class));
        $this->assertFalse($this->serviceLocator->has(self::class));
    }

    public function testGetWillInstantiateLogServiceIfNoInstanceHasBeenCreatedYet()
    {
        $this->serviceLocator->addClass(LogService::class, []);
        $logger = $this->serviceLocator->get(LogService::class);

        $this->assertInstanceOf(LogService::class, $logger);
    }
}
```

----

原文：

- https://laravel-china.org/docs/php-design-patterns/2018/ServiceLocator/1521