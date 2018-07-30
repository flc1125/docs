# 资源库模式（Repository）

## 1. 目的

该模式通过提供集合风格的接口来访问领域对象，从而协调领域和数据映射层。 资料库模式封装了一组存储在数据存储器里的对象和操作它们的方面，这样子为数据持久化层提供了更加面向对象的视角。资料库模式同时也达到了领域层与数据映射层之间清晰分离，单向依赖的目的。

## 2. 例子

- Doctrine 2 ORM: 通过资料库协调实体和 DBAL，它包含检索对象的方法。
- Laravel 框架

## 3. UML 图

![](https://lccdn.phphub.org/uploads/images/201803/19/1/d4WFKHUsdH.png)

## 4. 代码

你可以在 [GitHub](https://github.com/domnikl/DesignPatternsPHP/tree/master/More/Repository) 上找到这些代码

Post.php

```php
<?php

namespace DesignPatterns\More\Repository;

class Post
{
    /**
     * @var int|null
     */
    private $id;

    /**
     * @var string
     */
    private $title;

    /**
     * @var string
     */
    private $text;

    public static function fromState(array $state): Post
    {
        return new self(
            $state['id'],
            $state['title'],
            $state['text']
        );
    }

    /**
     * @param int|null $id
     * @param string $text
     * @param string $title
     */
    public function __construct($id, string $title, string $text)
    {
        $this->id = $id;
        $this->text = $text;
        $this->title = $title;
    }

    public function setId(int $id)
    {
        $this->id = $id;
    }

    public function getId(): int
    {
        return $this->id;
    }

    public function getText(): string
    {
        return $this->text;
    }

    public function getTitle(): string
    {
        return $this->title;
    }
}
```

PostRepository.php

```php
<?php

namespace DesignPatterns\More\Repository;

/**
 * 这个类位于实体层（Post 类）和访问对象层（内存）之间。
 *
 * 资源库封装了存储在数据存储中的对象集以及他们的操作执行
 * 为持久层提供更加面向对象的视图
 *
 * 在域和数据映射层之间，资源库还支持实现完全分离和单向依赖的目标。
 * 
 */
class PostRepository
{
    /**
     * @var MemoryStorage
     */
    private $persistence;

    public function __construct(MemoryStorage $persistence)
    {
        $this->persistence = $persistence;
    }

    public function findById(int $id): Post
    {
        $arrayData = $this->persistence->retrieve($id);

        if (is_null($arrayData)) {
            throw new \InvalidArgumentException(sprintf('Post with ID %d does not exist', $id));
        }

        return Post::fromState($arrayData);
    }

    public function save(Post $post)
    {
        $id = $this->persistence->persist([
            'text' => $post->getText(),
            'title' => $post->getTitle(),
        ]);

        $post->setId($id);
    }
}
```

MemoryStorage.php

```php
<?php

namespace DesignPatterns\More\Repository;

class MemoryStorage
{
    /**
     * @var array
     */
    private $data = [];

    /**
     * @var int
     */
    private $lastId = 0;

    public function persist(array $data): int
    {
        $this->lastId++;

        $data['id'] = $this->lastId;
        $this->data[$this->lastId] = $data;

        return $this->lastId;
    }

    public function retrieve(int $id): array
    {
        if (!isset($this->data[$id])) {
            throw new \OutOfRangeException(sprintf('No data found for ID %d', $id));
        }

        return $this->data[$id];
    }

    public function delete(int $id)
    {
        if (!isset($this->data[$id])) {
            throw new \OutOfRangeException(sprintf('No data found for ID %d', $id));
        }

        unset($this->data[$id]);
    }
}
```

## 5. 测试

Tests/RepositoryTest.php

```php
<?php

namespace DesignPatterns\More\Repository\Tests;

use DesignPatterns\More\Repository\MemoryStorage;
use DesignPatterns\More\Repository\Post;
use DesignPatterns\More\Repository\PostRepository;
use PHPUnit\Framework\TestCase;

class RepositoryTest extends TestCase
{
    public function testCanPersistAndFindPost()
    {
        $repository = new PostRepository(new MemoryStorage());
        $post = new Post(null, 'Repository Pattern', 'Design Patterns PHP');

        $repository->save($post);

        $this->assertEquals(1, $post->getId());
        $this->assertEquals($post->getId(), $repository->findById(1)->getId());
    }
}
```

----

原文：

- https://laravel-china.org/docs/php-design-patterns/2018/Repository/1522