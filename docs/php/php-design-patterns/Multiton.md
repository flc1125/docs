# 多例模式（Multiton）

**多例模式被公认为是 [反面模式](https://laravel-china.org/docs/php-design-patterns/2018/anti-pattern)，为了获得更好的可测试性和可维护性，请使用『[依赖注入模式](https://laravel-china.org/docs/php-design-patterns/2018/DependencyInjection)』。**

## 1. 目的

多例模式是指存在一个类有多个相同实例，而且该实例都是该类本身。这个类叫做多例类。 多例模式的特点是：

1. 多例类可以有多个实例。
1. 多例类必须自己创建、管理自己的实例，并向外界提供自己的实例。

多例模式实际上就是单例模式的推广。

## 2. 举例

- 2个数据库连接器，比如一个是 MySQL ，另一个是 SQLite
- 多个记录器（一个用于记录调试消息，一个用于记录错误）

## 3. UML 图

![](https://lccdn.phphub.org/uploads/images/201803/19/1/6rgmEPsepU.png)

## 4. 代码

你可以在这里找到源代码： [GitHub](https://github.com/domnikl/DesignPatternsPHP/tree/master/Creational/Multiton)

Multiton.php

```php
<?php

namespace DesignPatterns\Creational\Multiton;

final class Multiton
{
    const INSTANCE_1 = '1';
    const INSTANCE_2 = '2';

    /**
     * @var 实例数组
     */
    private static $instances = [];

    /**
     * 这里私有方法阻止用户随意的创建该对象实例
     */
    private function __construct()
    {
    }

    public static function getInstance(string $instanceName): Multiton
    {
        if (!isset(self::$instances[$instanceName])) {
            self::$instances[$instanceName] = new self();
        }

        return self::$instances[$instanceName];
    }

    /**
     * 该私有对象阻止实例被克隆
     */
    private function __clone()
    {
    }

    /**
     * 该私有方法阻止实例被序列化
     */
    private function __wakeup()
    {
    }
}
```

----

原文：

- https://laravel-china.org/docs/php-design-patterns/2018/Multiton/1490