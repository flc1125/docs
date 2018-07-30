# 规格模式（Specification）

## 1. 目的

构建一个清晰的业务规则规范，其中每条规则都能被针对性地检查。每个规范类中都有一个称为 `isSatisfiedBy` 的方法，方法判断给定的规则是否满足规范从而返回 `true` 或 `false`。

## 2. 例子

- RulerZ

## 3. UML 图

![](https://lccdn.phphub.org/uploads/images/201803/19/1/0tlZ6Tmsrn.png)

## 4. 代码

你可以在 [GitHub](https://github.com/domnikl/DesignPatternsPHP/tree/master/Behavioral/Specification) 中找到这段代码。

Item.php

```php
<?php

namespace DesignPatterns\Behavioral\Specification;

class Item
{
    /**
     * @var float
     */
    private $price;

    public function __construct(float $price)
    {
        $this->price = $price;
    }

    public function getPrice(): float
    {
        return $this->price;
    }
}
```

SpecificationInterface.php

```php
<?php

namespace DesignPatterns\Behavioral\Specification;

interface SpecificationInterface
{
    public function isSatisfiedBy(Item $item): bool;
}
```

OrSpecification.php

```php
<?php

namespace DesignPatterns\Behavioral\Specification;

class OrSpecification implements SpecificationInterface
{
    /**
     * @var SpecificationInterface[]
     */
    private $specifications;

    /**
     * @param SpecificationInterface[] ...$specifications
     */
    public function __construct(SpecificationInterface ...$specifications)
    {
        $this->specifications = $specifications;
    }

    /**
     * 如果有一条规则符合条件，返回 true，否则返回 false
     */
    public function isSatisfiedBy(Item $item): bool
    {
        foreach ($this->specifications as $specification) {
            if ($specification->isSatisfiedBy($item)) {
                return true;
            }
        }
        return false;
    }
}
```

PriceSpecification.php

```php
<?php

namespace DesignPatterns\Behavioral\Specification;

class PriceSpecification implements SpecificationInterface
{
    /**
     * @var float|null
     */
    private $maxPrice;

    /**
     * @var float|null
     */
    private $minPrice;

    /**
     * @param float $minPrice
     * @param float $maxPrice
     */
    public function __construct($minPrice, $maxPrice)
    {
        $this->minPrice = $minPrice;
        $this->maxPrice = $maxPrice;
    }

    public function isSatisfiedBy(Item $item): bool
    {
        if ($this->maxPrice !== null && $item->getPrice() > $this->maxPrice) {
            return false;
        }

        if ($this->minPrice !== null && $item->getPrice() < $this->minPrice) {
            return false;
        }

        return true;
    }
}
```

AndSpecification.php

```php
<?php

namespace DesignPatterns\Behavioral\Specification;

class AndSpecification implements SpecificationInterface
{
    /**
     * @var SpecificationInterface[]
     */
    private $specifications;

    /**
     * @param SpecificationInterface[] ...$specifications
     */
    public function __construct(SpecificationInterface ...$specifications)
    {
        $this->specifications = $specifications;
    }

    /**
     * 如果有一条规则不符合条件，返回 false，否则返回 true
     */
    public function isSatisfiedBy(Item $item): bool
    {
        foreach ($this->specifications as $specification) {
            if (!$specification->isSatisfiedBy($item)) {
                return false;
            }
        }

        return true;
    }
}
```

NotSpecification.php

```php
<?php

namespace DesignPatterns\Behavioral\Specification;

class NotSpecification implements SpecificationInterface
{
    /**
     * @var SpecificationInterface
     */
    private $specification;

    public function __construct(SpecificationInterface $specification)
    {
        $this->specification = $specification;
    }

    public function isSatisfiedBy(Item $item): bool
    {
        return !$this->specification->isSatisfiedBy($item);
    }
}
```

## 5. 测试

Tests/SpecificationTest.php

```php
<?php

namespace DesignPatterns\Behavioral\Specification\Tests;

use DesignPatterns\Behavioral\Specification\Item;
use DesignPatterns\Behavioral\Specification\NotSpecification;
use DesignPatterns\Behavioral\Specification\OrSpecification;
use DesignPatterns\Behavioral\Specification\AndSpecification;
use DesignPatterns\Behavioral\Specification\PriceSpecification;
use PHPUnit\Framework\TestCase;

class SpecificationTest extends TestCase
{
    public function testCanOr()
    {
        $spec1 = new PriceSpecification(50, 99);
        $spec2 = new PriceSpecification(101, 200);

        $orSpec = new OrSpecification($spec1, $spec2);

        $this->assertFalse($orSpec->isSatisfiedBy(new Item(100)));
        $this->assertTrue($orSpec->isSatisfiedBy(new Item(51)));
        $this->assertTrue($orSpec->isSatisfiedBy(new Item(150)));
    }

    public function testCanAnd()
    {
        $spec1 = new PriceSpecification(50, 100);
        $spec2 = new PriceSpecification(80, 200);

        $andSpec = new AndSpecification($spec1, $spec2);

        $this->assertFalse($andSpec->isSatisfiedBy(new Item(150)));
        $this->assertFalse($andSpec->isSatisfiedBy(new Item(1)));
        $this->assertFalse($andSpec->isSatisfiedBy(new Item(51)));
        $this->assertTrue($andSpec->isSatisfiedBy(new Item(100)));
    }

    public function testCanNot()
    {
        $spec1 = new PriceSpecification(50, 100);
        $notSpec = new NotSpecification($spec1);

        $this->assertTrue($notSpec->isSatisfiedBy(new Item(150)));
        $this->assertFalse($notSpec->isSatisfiedBy(new Item(50)));
    }
}
```

----

原文：

- https://laravel-china.org/docs/php-design-patterns/2018/Specification/1514