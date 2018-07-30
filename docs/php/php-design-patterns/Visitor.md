# 模板方法模式（Template Method）

## 1. 目的

访问者模式可以让你将对象操作外包给其他对象。这样做的最主要原因就是关注（数据结构和数据操作）分离。但是被访问的类必须定一个契约接受访问者。 (详见例子中的 `Role::accept` 方法)

契约可以是一个抽象类也可直接就是一个接口。在此情况下，每个访问者必须自行选择调用访问者的哪个方法。

## 2. UML 图

![](https://lccdn.phphub.org/uploads/images/201803/19/1/rtMmvjqvbN.png)

## 3. 代码

你可以在 [GitHub](https://github.com/domnikl/DesignPatternsPHP/tree/master/Behavioral/Visitor) 上找到这些代码

RoleVisitorInterface.php

```php
<?php

namespace DesignPatterns\Behavioral\Visitor;

/**
 * 注意：访问者不能自行选择调用哪个方法，
 * 它是由 Visitee 决定的。
 */
interface RoleVisitorInterface
{
    public function visitUser(User $role);

    public function visitGroup(Group $role);
}
```

RoleVisitor.php

```php
<?php

namespace DesignPatterns\Behavioral\Visitor;

class RoleVisitor implements RoleVisitorInterface
{
    /**
     * @var Role[]
     */
    private $visited = [];

    public function visitGroup(Group $role)
    {
        $this->visited[] = $role;
    }

    public function visitUser(User $role)
    {
        $this->visited[] = $role;
    }

    /**
     * @return Role[]
     */
    public function getVisited(): array
    {
        return $this->visited;
    }
}
```

Role.php

```php
<?php

namespace DesignPatterns\Behavioral\Visitor;

interface Role
{
    public function accept(RoleVisitorInterface $visitor);
}
```

User.php

```php
<?php

namespace DesignPatterns\Behavioral\Visitor;

class User implements Role
{
    /**
     * @var string
     */
    private $name;

    public function __construct(string $name)
    {
        $this->name = $name;
    }

    public function getName(): string
    {
        return sprintf('User %s', $this->name);
    }

    public function accept(RoleVisitorInterface $visitor)
    {
        $visitor->visitUser($this);
    }
}
```

Group.php

```php
<?php

namespace DesignPatterns\Behavioral\Visitor;

class Group implements Role
{
    /**
     * @var string
     */
    private $name;

    public function __construct(string $name)
    {
        $this->name = $name;
    }

    public function getName(): string
    {
        return sprintf('Group: %s', $this->name);
    }

    public function accept(RoleVisitorInterface $visitor)
    {
        $visitor->visitGroup($this);
    }
}
```

## 4. 测试

Tests/VisitorTest.php

```php
<?php

namespace DesignPatterns\Tests\Visitor\Tests;

use DesignPatterns\Behavioral\Visitor;
use PHPUnit\Framework\TestCase;

class VisitorTest extends TestCase
{
    /**
     * @var Visitor\RoleVisitor
     */
    private $visitor;

    protected function setUp()
    {
        $this->visitor = new Visitor\RoleVisitor();
    }

    public function provideRoles()
    {
        return [
            [new Visitor\User('Dominik')],
            [new Visitor\Group('Administrators')],
        ];
    }

    /**
     * @dataProvider provideRoles
     *
     * @param Visitor\Role $role
     */
    public function testVisitSomeRole(Visitor\Role $role)
    {
        $role->accept($this->visitor);
        $this->assertSame($role, $this->visitor->getVisited()[0]);
    }
}
```

----

原文：

- https://laravel-china.org/docs/php-design-patterns/2018/Visitor/1519