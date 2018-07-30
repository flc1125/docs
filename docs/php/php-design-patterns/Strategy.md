# 策略模式（Strategy）

## 1. 术语：

- 上下文
- 策略
- 具体策略

## 2. 目的

分离「策略」并使他们之间能互相快速切换。此外，这种模式是一种不错的继承替代方案（替代使用扩展抽象类的方式）。

## 3. 例子

- 对一个对象列表进行排序，一种按照日期，一种按照 id
- 简化版的的单元测试：例如，在使用文件存储和内存存储之间互相切换

## 4. UML 图

![](https://lccdn.phphub.org/uploads/images/201803/19/1/ZALJKc6DB2.png)

## 5. 代码

你可以在 [GitHub](https://github.com/domnikl/DesignPatternsPHP/tree/master/Behavioral/Strategy) 上找到这个代码。

Context.php

```php
<?php

namespace DesignPatterns\Behavioral\Strategy;

class Context
{
    /**
     * @var ComparatorInterface
     */
    private $comparator;

    public function __construct(ComparatorInterface $comparator)
    {
        $this->comparator = $comparator;
    }

    public function executeStrategy(array $elements) : array
    {
        uasort($elements, [$this->comparator, 'compare']);

        return $elements;
    }
}
```

ComparatorInterface.php

```php
<?php

namespace DesignPatterns\Behavioral\Strategy;

interface ComparatorInterface
{
    /**
     * @param mixed $a
     * @param mixed $b
     *
     * @return int
     */
    public function compare($a, $b): int;
}
```

DateComparator.php

```php
<?php

namespace DesignPatterns\Behavioral\Strategy;

class DateComparator implements ComparatorInterface
{
    /**
     * @param mixed $a
     * @param mixed $b
     *
     * @return int
     */
    public function compare($a, $b): int
    {
        $aDate = new \DateTime($a['date']);
        $bDate = new \DateTime($b['date']);

        return $aDate <=> $bDate;
    }
}
```

IdComparator.php

```php
<?php

namespace DesignPatterns\Behavioral\Strategy;

class IdComparator implements ComparatorInterface
{
    /**
     * @param mixed $a
     * @param mixed $b
     *
     * @return int
     */
    public function compare($a, $b): int
    {
        return $a['id'] <=> $b['id'];
    }
}
```

## 6. 测试

Tests/StrategyTest.php

```php
<?php

namespace DesignPatterns\Behavioral\Strategy\Tests;

use DesignPatterns\Behavioral\Strategy\Context;
use DesignPatterns\Behavioral\Strategy\DateComparator;
use DesignPatterns\Behavioral\Strategy\IdComparator;
use PHPUnit\Framework\TestCase;

class StrategyTest extends TestCase
{
    public function provideIntegers()
    {
        return [
            [
                [['id' => 2], ['id' => 1], ['id' => 3]],
                ['id' => 1],
            ],
            [
                [['id' => 3], ['id' => 2], ['id' => 1]],
                ['id' => 1],
            ],
        ];
    }

    public function provideDates()
    {
        return [
            [
                [['date' => '2014-03-03'], ['date' => '2015-03-02'], ['date' => '2013-03-01']],
                ['date' => '2013-03-01'],
            ],
            [
                [['date' => '2014-02-03'], ['date' => '2013-02-01'], ['date' => '2015-02-02']],
                ['date' => '2013-02-01'],
            ],
        ];
    }

    /**
     * @dataProvider provideIntegers
     *
     * @param array $collection
     * @param array $expected
     */
    public function testIdComparator($collection, $expected)
    {
        $obj = new Context(new IdComparator());
        $elements = $obj->executeStrategy($collection);

        $firstElement = array_shift($elements);
        $this->assertEquals($expected, $firstElement);
    }

    /**
     * @dataProvider provideDates
     *
     * @param array $collection
     * @param array $expected
     */
    public function testDateComparator($collection, $expected)
    {
        $obj = new Context(new DateComparator());
        $elements = $obj->executeStrategy($collection);

        $firstElement = array_shift($elements);
        $this->assertEquals($expected, $firstElement);
    }
}
```

----

原文：

- https://laravel-china.org/docs/php-design-patterns/2018/Strategy/1516