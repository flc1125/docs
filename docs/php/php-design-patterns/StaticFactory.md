# 静态工厂模式（Static Factory）

## 1. 目的

与抽象工厂模式类似，此模式用于创建一系列相关或相互依赖的对象。 『静态工厂模式』与『抽象工厂模式』的区别在于，只使用一个静态方法来创建所有类型对象， 此方法通常被命名为 `factory` 或 `build`。

## 2. 例子

- Zend Framework: `Zend_Cache_Backend` 或 `_Frontend` 使用工厂方法创建缓存后端或前端

## 3. UML 图

![](https://lccdn.phphub.org/uploads/images/201803/19/1/wZFkQjM3UG.png)

## 4. 代码

你可以在 [GitHub](https://github.com/domnikl/DesignPatternsPHP/tree/master/Creational/StaticFactory) 上找到这个代码。

StaticFactory.php

```php
<?php

namespace DesignPatterns\Creational\StaticFactory;

/**
 * 注意点1: 记住，静态意味着全局状态，因为它不能被模拟进行测试，所以它是有弊端的
 * 注意点2: 不能被分类或模拟或有多个不同的实例。
 */
final class StaticFactory
{
    /**
    * @param string $type
    *
    * @return FormatterInterface
    */
    public static function factory(string $type): FormatterInterface
    {
        if ($type == 'number') {
            return new FormatNumber();
        }

        if ($type == 'string') {
            return new FormatString();
        }

        throw new \InvalidArgumentException('Unknown format given');
    }
}
```

FormatterInterface.php

```php
<?php

namespace DesignPatterns\Creational\StaticFactory;

interface FormatterInterface
{
}
```

FormatString.php

```php
<?php

namespace DesignPatterns\Creational\StaticFactory;

class FormatString implements FormatterInterface
{
}
```

FormatNumber.php

```php
<?php

namespace DesignPatterns\Creational\StaticFactory;

class FormatNumber implements FormatterInterface
{
}
```

## 5. 测试

Tests/StaticFactoryTest.php

```php
<?php

namespace DesignPatterns\Creational\StaticFactory\Tests;

use DesignPatterns\Creational\StaticFactory\StaticFactory;
use PHPUnit\Framework\TestCase;

class StaticFactoryTest extends TestCase
{
    public function testCanCreateNumberFormatter()
    {
        $this->assertInstanceOf(
            'DesignPatterns\Creational\StaticFactory\FormatNumber',
            StaticFactory::factory('number')
        );
    }

    public function testCanCreateStringFormatter()
    {
        $this->assertInstanceOf(
            'DesignPatterns\Creational\StaticFactory\FormatString',
            StaticFactory::factory('string')
        );
    }

    /**
    * @expectedException \InvalidArgumentException
    */
    public function testException()
    {
        StaticFactory::factory('object');
    }
}
```

----

原文：

- https://laravel-china.org/docs/php-design-patterns/2018/StaticFactory/1495