# 原型模式（Prototype）

> 原文：https://laravel-china.org/docs/php-design-patterns/2018/Prototype/1492

## 1. 目的

相比正常创建一个对象 `(new Foo())`，首先创建一个原型，然后克隆它会更节省开销。

## 2. 示例

- 大数据量 ( 例如：通过 ORM 模型一次性往数据库插入 1,000,000 条数据 ) 。

## 3. UML 图

![](https://lccdn.phphub.org/uploads/images/201803/19/1/jNhFZSU2j5.png)

## 4. 代码

完整代码请看 [GitHub](https://github.com/domnikl/DesignPatternsPHP/tree/master/Creational/Prototype)

BookPrototype.php

```php
<?php

namespace DesignPatterns\Creational\Prototype;

abstract class BookPrototype
{
    /**
    * @var string
    */
    protected $title;

    /**
    * @var string
    */
    protected $category;

    abstract public function __clone();

    public function getTitle(): string
    {
        return $this->title;
    }

    public function setTitle($title)
    {
        $this->title = $title;
    }
}
```

BarBookPrototype.php

```php
<?php

namespace DesignPatterns\Creational\Prototype;

class BarBookPrototype extends BookPrototype
{
    /**
    * @var string
    */
    protected $category = 'Bar';

    public function __clone()
    {
    }
}
```

FooBookPrototype.php

```php
<?php

namespace DesignPatterns\Creational\Prototype;

class FooBookPrototype extends BookPrototype
{
    /**
    * @var string
    */
    protected $category = 'Foo';

    public function __clone()
    {
    }
}
```

## 5. 测试

Tests/PrototypeTest.php

```php
<?php

namespace DesignPatterns\Creational\Prototype\Tests;

use DesignPatterns\Creational\Prototype\BarBookPrototype;
use DesignPatterns\Creational\Prototype\FooBookPrototype;
use PHPUnit\Framework\TestCase;

class PrototypeTest extends TestCase
{
    public function testCanGetFooBook()
    {
        $fooPrototype = new FooBookPrototype();
        $barPrototype = new BarBookPrototype();

        for ($i = 0; $i < 10; $i++) {
            $book = clone $fooPrototype;
            $book->setTitle('Foo Book No ' . $i);
            $this->assertInstanceOf(FooBookPrototype::class, $book);
        }

        for ($i = 0; $i < 5; $i++) {
            $book = clone $barPrototype;
            $book->setTitle('Bar Book No ' . $i);
            $this->assertInstanceOf(BarBookPrototype::class, $book);
        }
    }
}
```