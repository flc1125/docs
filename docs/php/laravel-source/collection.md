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
collect([1, 2, 3])->all(); [1, 2, 3];
```

### `lazy()`

`lazy()` 创建一个惰性集合（支持迭代器，性能更优）

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

### `mode()`

### `collapse()`

### `contains()`

### `crossJoin()`

### `diff()`

### `diffUsing()`

### `diffAssoc()`

### `diffAssocUsing()`

### `diffKeys()`

### `diffKeysUsing()`

### `duplicates()`

### `duplicatesStrict()`

### `except()`

### `filter()`

### `first()`

### `flatten()`

### `flip()`

### `forget()`

### `get()`

### `groupBy()`

### `keyBy()`

### `has()`

### `implode()`

### `intersect()`

### `intersectByKeys()`

### `isEmpty()`

`isEmpty()` 判定数据集合是否为空，如果集合为空，返回 `true` ，否则返回 `false`

```php
collect([])->isEmpty(); // true
```

### `join()`

### `keys()`

### `last()`

### `pluck()`

### `map()`

### `mapToDictionary()`

### `mapWithKeys()`

### `merge()`

### `mergeRecursive()`

### `combine()`

### `union()`

### `nth()`

### `only()`

### `pop()`

### `prepend()`

### `push()`

### `concat()`

### `pull()`

### `put()`

### `random()`

### `reduce()`

### `replace()`

### `replaceRecursive()`

### `reverse()`

### `search()`

### `shift()`

### `shuffle()`

### `skip()`

### `skipUntil()`

### `skipWhile()`

### `slice()`

### `split()`

### `chunk()`

`chunk($size)` 针对集合数据进行分组

```php
$chunks = collect([1, 2, 3, 4, 5, 6, 7])->chunk(3);  // 按三个一组进行拆分

$chunks->toArray(); // [[1, 2, 3], [4, 5, 6], [7]]t
```

当使用如 `Bootstrap` 那样的栅格系统时，该方法在视图中相当有用。想象一下你有个想在栅格显示的 `Eloquent` 模型：

```php
@foreach ($products->chunk(3) as $chunk)
    <div class="row">
        @foreach ($chunk as $product)
            <div class="col-xs-4">{{ $product->name }}</div>
        @endforeach
    </div>
@endforeach
```

### `sort()`

### `sortDesc()`

### `sortBy()`

### `sortByDesc()`

### `sortKeys()`

### `sortKeysDesc()`

### `splice()`

### `take()`

### `takeUntil()`

### `takeWhile()`

### `transform()`

### `values()`

### `zip()`

### `pad()`

`pad($size, $value)` 补足指定数量的指定值到集合数据中

```php
collect([1, 2, 3])->pad(6, 123); // collect([1, 2, 3, 123, 123, 123])
```

### `getIterator()`

### `count()`

`count()` 返回集合的总数

```php
collect([1, 2, 3])->count(); // 3
```

### `add()`

`add($item)` 追加一个数据到集合中，并返回当前集合

```php
collect([1, 2, 3])->add(4); // collect([1, 2, 3, 4])
```

### `toBase()`

`toBase()` 基于当前集合，返回一个新的集合

### `offsetExists()`

`offsetExists($key)` 判定集合的指定下标是否存在

```php
$collect = collect([
    'name' => 1,
    'username' => 222,
]);

$collect->offsetExists('name');  // 1
```

### `offsetGet()`

`offsetGet($key)` 获取集合中指定下标的数据

```php
$collect = collect([
    'name' => 111,
    'username' => 222,
]);

$collect->offsetGet('name');  // 111
```

### `offsetSet()`

`offsetSet($key, $value)` 向集合设置指定下标的数据；若下标未定义(`null`)，则追加数据

```php
$collect = collect([
    'name' => 111,
    'username' => 222,
]);

$collect->offsetSet('name', '123123');  // 赋值
$collect->offsetGet('name');  // 123123

$collect->offsetSet(null, '3234234');  // 追加
```

### `offsetUnset()`

`offsetUnset($key)` 删除集合中指定下标的数据

```php
$collect = collect([
    'name' => 111,
    'username' => 222,
]);

$collect->offsetUnset('name');
```

## 扩展集合

集合都是「可宏扩展」(`macroable`) 的，它允许你在执行时将其它方法添加到 `Collection` 类。

例如，通过下面的代码在 `Collection` 类中添加一个 `prefix` 方法：

```php tab="PHP"
Collection::macro('prefix', function ($prefix = '') {  // 参数传入位置
    return $this->map(function ($value) use ($prefix) {  // 注意此处是 $this
        return $prefix.$value;
    });
});

collect([1, 2, 3])->prefix('tests');
```

``` tab="Result"
Illuminate\Support\Collection Object
(
    [items:protected] => Array
        (
            [0] => tests1
            [1] => tests2
            [2] => tests3
        )

)
```

> 通常在服务提供者中定义扩展集合方法。

## 相关文件

- LearnKu：https://learnku.com/docs/laravel/7.x/collections/7483
- 集合类：`/vendor/laravel/framework/src/Illuminate/Support/Collection.php`
- 创建集合：`/app/Console/Commands/Collection/Create.php`
- `/app/Console/Commands/Collection/Functions.php`