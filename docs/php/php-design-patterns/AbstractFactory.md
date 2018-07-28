# 抽象工厂模式（Abstract Factory）

> 原文：https://laravel-china.org/docs/php-design-patterns/2018/AbstractFactory/1487

## 1. 目的

在不指定具体类的情况下创建一系列相关或依赖对象。 通常创建的类都实现相同的接口。 抽象工厂的客户并不关心这些对象是如何创建的，它只是知道它们是如何一起运行的。

## 2. UML 图

![](https://lccdn.phphub.org/uploads/images/201803/19/1/UMD5mQUIFw.png)

## 3. 代码

你可以在 [GitHub](https://github.com/domnikl/DesignPatternsPHP/tree/master/Creational/AbstractFactory) 上找到这个代码。

AbstractFactory.php

```php
<?php

namespace DesignPatterns\Creational\AbstractFactory;

/**
 * 在这种情况下，抽象工厂是创建一些组件的契约
 * 在 Web 中。 有两种呈现文本的方式：HTML 和 JSON
 */
abstract class AbstractFactory
{
    abstract public function createText(string $content): Text;
}
```

JsonFactory.php

```php
<?php

namespace DesignPatterns\Creational\AbstractFactory;

class JsonFactory extends AbstractFactory
{
    public function createText(string $content): Text
    {
        return new JsonText($content);
    }
}
```

HtmlFactory.php

```php
<?php

namespace DesignPatterns\Creational\AbstractFactory;

class HtmlFactory extends AbstractFactory
{
    public function createText(string $content): Text
    {
        return new HtmlText($content);
    }
}
```

Text.php

```php
<?php

namespace DesignPatterns\Creational\AbstractFactory;

abstract class Text
{
    /**
     * @var string
     */
    private $text;

    public function __construct(string $text)
    {
        $this->text = $text;
    }
}
```

JsonText.php

```php
<?php

namespace DesignPatterns\Creational\AbstractFactory;

class JsonText extends Text
{
    // 你的逻辑代码
}
```

HtmlText.php

```php
<?php

namespace DesignPatterns\Creational\AbstractFactory;

class HtmlText extends Text
{
    // 你的逻辑代码
}
```

## 4. Test

Tests/AbstractFactoryTest.php

```php
<?php

namespace DesignPatterns\Creational\AbstractFactory\Tests;

use DesignPatterns\Creational\AbstractFactory\HtmlFactory;
use DesignPatterns\Creational\AbstractFactory\HtmlText;
use DesignPatterns\Creational\AbstractFactory\JsonFactory;
use DesignPatterns\Creational\AbstractFactory\JsonText;
use PHPUnit\Framework\TestCase;

class AbstractFactoryTest extends TestCase
{
    public function testCanCreateHtmlText()
    {
        $factory = new HtmlFactory();
        $text = $factory->createText('foobar');

        $this->assertInstanceOf(HtmlText::class, $text);
    }

    public function testCanCreateJsonText()
    {
        $factory = new JsonFactory();
        $text = $factory->createText('foobar');

        $this->assertInstanceOf(JsonText::class, $text);
    }
}
```