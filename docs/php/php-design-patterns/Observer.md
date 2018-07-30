# 观察者模式（Observer）

## 1. 目的

当对象的状态发生变化时，所有依赖于它的对象都得到通知并被自动更新。它使用的是低耦合的方式。

## 2. 例子

使用观察者模式观察消息队列在 GUI 中的运行情况。

## 3. 注意

PHP 已经定义了2个接口用于快速实现观察者模式：`SplObserver` 和 `SplSubject`。

## 4. UML 图

![](https://lccdn.phphub.org/uploads/images/201803/19/1/sWK78CV3NN.png)

## 5. 代码

你可以在 [GitHub](https://github.com/domnikl/DesignPatternsPHP/tree/master/Behavioral/Observer) 查看这段代码。

User.php

```php
<?php

namespace DesignPatterns\Behavioral\Observer;

/**
 * User 实现观察者模式 (称为主体)，它维护一个观察者列表，
 * 当对象发生变化时通知  User。
 */
class User implements \SplSubject
{
    /**
     * @var string
     */
    private $email;

    /**
     * @var \SplObjectStorage
     */
    private $observers;

    public function __construct()
    {
        $this->observers = new \SplObjectStorage();
    }

    public function attach(\SplObserver $observer)
    {
        $this->observers->attach($observer);
    }

    public function detach(\SplObserver $observer)
    {
        $this->observers->detach($observer);
    }

    public function changeEmail(string $email)
    {
        $this->email = $email;
        $this->notify();
    }

    public function notify()
    {
        /** @var \SplObserver $observer */
        foreach ($this->observers as $observer) {
            $observer->update($this);
        }
    }
}
```

UserObserver.php

```php
<?php

namespace DesignPatterns\Behavioral\Observer;

class UserObserver implements \SplObserver
{
    /**
     * @var User[]
     */
    private $changedUsers = [];

    /**
     * 它通常使用  SplSubject::notify()  通知主体
     *
     * @param \SplSubject $subject
     */
    public function update(\SplSubject $subject)
    {
        $this->changedUsers[] = clone $subject;
    }

    /**
     * @return User[]
     */
    public function getChangedUsers(): array
    {
        return $this->changedUsers;
    }
}
```

## 6. 测试

Tests/ObserverTest.php

```php
<?php

namespace DesignPatterns\Behavioral\Observer\Tests;

use DesignPatterns\Behavioral\Observer\User;
use DesignPatterns\Behavioral\Observer\UserObserver;
use PHPUnit\Framework\TestCase;

class ObserverTest extends TestCase
{
    public function testChangeInUserLeadsToUserObserverBeingNotified()
    {
        $observer = new UserObserver();

        $user = new User();
        $user->attach($observer);

        $user->changeEmail('foo@bar.com');
        $this->assertCount(1, $observer->getChangedUsers());
    }
}
```

----

原文：

- https://laravel-china.org/docs/php-design-patterns/2018/Observer/1513