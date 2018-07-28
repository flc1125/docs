# 适配器模式（Adapter）

> 原文：https://laravel-china.org/docs/php-design-patterns/2018/Adapter/1496

## 1. 目的

将一个类的接口转换成可应用的兼容接口。适配器使原本由于接口不兼容而不能一起工作的那些类可以一起工作。

## 2. 例子

- 客户端数据库适配器
- 使用多个不同的网络服务和适配器来规范数据使得出结果是相同的

## 3. UML 图

![](https://lccdn.phphub.org/uploads/images/201803/19/1/oHBRHvqDHI.png)

## 4. 代码

你也可以在 [GitHub](https://github.com/domnikl/DesignPatternsPHP/tree/master/Structural/Adapter) 上查看代码

BookInterface.php

```php
<?php

namespace DesignPatterns\Structural\Adapter;

interface BookInterface
{
    public function turnPage();

    public function open();

    public function getPage(): int;
}
```

Book.php

```php
<?php

namespace DesignPatterns\Structural\Adapter;

class Book implements BookInterface
{
    /**
    * @var int
    */
    private $page;

    public function open()
    {
        $this->page = 1;
    }

    public function turnPage()
    {
        $this->page++;
    }

    public function getPage(): int
    {
        return $this->page;
    }
}
```

EBookAdapter.php

```php
<?php

namespace DesignPatterns\Structural\Adapter;

/**
* 这里是一个适配器. 注意他实现了 BookInterface,
* 因此你不必去更改客户端代码当使用 Book
*/
class EBookAdapter implements BookInterface
{
    /**
    * @var EBookInterface
    */
    protected $eBook;

    /**
    * @param EBookInterface $eBook
    */
    public function __construct(EBookInterface $eBook)
    {
        $this->eBook = $eBook;
    }

    /**
    * 这个类使接口进行适当的转换.
    */
    public function open()
    {
        $this->eBook->unlock();
    }

    public function turnPage()
    {
        $this->eBook->pressNext();
    }

    /**
    * 注意这里适配器的行为： EBookInterface::getPage() 将返回两个整型，除了 BookInterface
    * 仅支持获得当前页，所以我们这里适配这个行为
    *
    * @return int
    */
    public function getPage(): int
    {
        return $this->eBook->getPage()[0];
    }
}
```

EBookInterface.php

```php
<?php

namespace DesignPatterns\Structural\Adapter;

interface EBookInterface
{
    public function unlock();

    public function pressNext();

    /**
    * 返回当前页和总页数，像 [10, 100] 是总页数100中的第10页。
    *
    * @return int[]
    */
    public function getPage(): array;
}
```

Kindle.php

```php
<?php

namespace DesignPatterns\Structural\Adapter;

/**
* 这里是适配过的类. 在生产代码中, 这可能是来自另一个包的类，一些供应商提供的代码。
* 注意它使用了另一种命名方案并用另一种方式实现了类似的操作
*/
class Kindle implements EBookInterface
{
    /**
    * @var int
    */
    private $page = 1;

    /**
    * @var int
    */
    private $totalPages = 100;

    public function pressNext()
    {
        $this->page++;
    }

    public function unlock()
    {
    }

    /**
    * 返回当前页和总页数，像 [10, 100] 是总页数100中的第10页。
    *
    * @return int[]
    */
    public function getPage(): array
    {
        return [$this->page, $this->totalPages];
    }
}
```

## 5. 测试

Tests/AdapterTest.php

```php
<?php

namespace DesignPatterns\Structural\Adapter\Tests;

use DesignPatterns\Structural\Adapter\Book;
use DesignPatterns\Structural\Adapter\EBookAdapter;
use DesignPatterns\Structural\Adapter\Kindle;
use PHPUnit\Framework\TestCase;

class AdapterTest extends TestCase
{
    public function testCanTurnPageOnBook()
    {
        $book = new Book();
        $book->open();
        $book->turnPage();

        $this->assertEquals(2, $book->getPage());
    }

    public function testCanTurnPageOnKindleLikeInANormalBook()
    {
        $kindle = new Kindle();
        $book = new EBookAdapter($kindle);

        $book->open();
        $book->turnPage();

        $this->assertEquals(2, $book->getPage());
    }
}
```