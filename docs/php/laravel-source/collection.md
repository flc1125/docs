# Collection 集合

## 概述

`Illuminate\Support\Collection` 提供一个处理数组的数据封装类。

本文核心文件（含相关注释）：[Collection.php](https://github.com/flc1125/learn-laravel/blob/master/vendor/laravel/framework/src/Illuminate/Support/Collection.php)

## 创建集合

```php tab="PHP"
use Illuminate\Support\Collection;

// 类直接创建
$collect = new Collection([1, 3, 5]);

// 静态方法创建
$collect = Collection::make([1, 2, 4]);

// 创建指定数量的集合
$collect = Collection::times(3);

// 创建指定数量，并经过回调函数处理的集合
$collect = Collection::times(3, function ($value) {
    return [
        'value' => $value,
        'name'  => 'tests:'.$value,
    ];
});

// 通过函数快速创建
$collect = collect([1, 2, 3]);
```

``` tab="Result"
Illuminate\Support\Collection Object
(
    [items:protected] => Array
        (
            [0] => 1
            [1] => 3
            [2] => 5
        )

)

Illuminate\Support\Collection Object
(
    [items:protected] => Array
        (
            [0] => 1
            [1] => 2
            [2] => 4
        )

)

Illuminate\Support\Collection Object
(
    [items:protected] => Array
        (
            [0] => 1
            [1] => 2
            [2] => 3
        )

)

Illuminate\Support\Collection Object
(
    [items:protected] => Array
        (
            [0] => Array
                (
                    [value] => 1
                    [name] => tests:1
                )

            [1] => Array
                (
                    [value] => 2
                    [name] => tests:2
                )

            [2] => Array
                (
                    [value] => 3
                    [name] => tests:3
                )

        )

)

Illuminate\Support\Collection Object
(
    [items:protected] => Array
        (
            [0] => 1
            [1] => 3
            [2] => 5
        )

)
```

## 集合方法

### `all()`

`all()` 返回集合所有数据

```php
$collect = collect([1, 2, 3]);

print_r($collect->all());

// Array
// (
//     [0] => 1
//     [1] => 2
//     [2] => 3
// )
```

### `lazy()`

`lazy()` 创建一个懒集合（支持迭代器，性能更优）

### `avg()`

`avg($callback = null)` 获取平均值，支持回调函数

```php
collect([1, 2, 3])->avg();  // 2

$collect = collect([
    ['name' => 1, 'value' => '123'],
    ['name' => 2, 'value' => '222'],
    ['name' => 3, 'value' => '444'],
]);

// 指定字段
$collect->avg('value');  // 263

// 回调函数
$collect->avg(function ($value) {
    return $value['value'];
});  // 263
```

### `median()`

`median($key = null)` 获取中位数

```php
collect([1, 2, 3])->median(); // 2

collect([
    ['name' => 1, 'value' => '123'],
    ['name' => 2, 'value' => '222'],
    ['name' => 3, 'value' => '444'],
])->median('value');  // 222
```







## 相关文件

- 集合类：`/vendor/laravel/framework/src/Illuminate/Support/Collection.php`
- 创建集合：`/app/Console/Commands/Collection/Create.php`
- `/app/Console/Commands/Collection/Functions.php`