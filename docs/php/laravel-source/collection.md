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
collect([1, 2, 3])->all(); // [1, 2, 3];
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

> 源码用了一些技巧，可读源码学习。

### `mode()`

### `collapse()`

### `contains()`

### `crossJoin()`

`crossJoin(...$lists)` 与多个集合互相组合，返回组合后的笛卡尔积集合

```php tab="PHP"
collect(['X', 'XL'])->crossJoin(['红色', '白色', '紫色'], ['长款', '短款']);
```

``` tab="Result"
Illuminate\Support\Collection {#3029
     all: [
       [
         "X",
         "红色",
         "长款",
       ],
       [
         "X",
         "红色",
         "短款",
       ],
       [
         "X",
         "白色",
         "长款",
       ],
       [
         "X",
         "白色",
         "短款",
       ],
       [
         "X",
         "紫色",
         "长款",
       ],
       [
         "X",
         "紫色",
         "短款",
       ],
       [
         "XL",
         "红色",
         "长款",
       ],
       [
         "XL",
         "红色",
         "短款",
       ],
       [
         "XL",
         "白色",
         "长款",
       ],
       [
         "XL",
         "白色",
         "短款",
       ],
       [
         "XL",
         "紫色",
         "长款",
       ],
       [
         "XL",
         "紫色",
         "短款",
       ],
     ],
   }
```

> 该方法常用于电商。方法存在一些技巧。

### `diff()`

### `diffUsing()`

### `diffAssoc()`

### `diffAssocUsing()`

### `diffKeys()`

### `diffKeysUsing()`

### `duplicates()`

### `duplicatesStrict()`

### `except()`

`except($keys)` 返回排除指定 key 的新集合

```php
collect(['a' => 1, 'b' => 2, 'c' => 3])->except(['a', 'b']);
// collect(['c' => 3])
```

### `filter()`

`filter(callable $callback = null)` 通过给定的回调函数过滤集合，保留通过了解的集合数据；如果不设置回调函数，则集合中所有值符合 `false` 的将会被移除。

```php
collect(['a' => 1, 'b' => 2, 'c' => '', 'd' => 0])->filter();
// collect(['a' => 1, 'b' => 2])

collect(['a' => 1, 'b' => 2, 'c' => '', 'd' => 0])->filter(function ($value) {
    return $value !== 0;
});
// collect(['a' => 1, 'b' => 2, 'c' => ''])
```

### `first()`

`first(callable $callback = null, $default = null)` 从集合中返回符合条件的第一个值，支持回调函数；`$default` 为默认值。

```php
collect()->first(); // null
collect()->first(null, 1);  // 1
collect([1, 2])->first(function ($value) {
    return $value == 2;
});  // 2

collect([1, 2])->first(function ($value) {
    return $value == 3;
});  // null

collect([1, 2])->first(function ($value) {
    return $value == 3;
}, function () {
    return 333;
});  // 333
```

### `flatten()`

`flatten($depth = INF)` 将多维集合转换为一维集合，其中 `$depth` 为转换深度，默认无穷大。

> `INF` 为 PHP 常量，含义：无穷

```php
collect(['a' => 1, 'b' => [2, 3]])->flatten();  // collect([1, 2, 3])
collect(['a' => 1, 'b' => [2, 'c' => 3, 'd' => [4, 5]]])->flatten(1);  // collect([1, 2, 3, [4, 5]])
```

### `flip()`

`flip()` 将集合的键和对应的值进行互换；转换后，遇到相同的键，后面的值会替换前面的

```php
collect(['a' => 1, 'b' => 2])->flip(); // collect(['1' => 'a', '2' => 'b'])
collect(['a' => 1, 'b' => 2 , 'c' => 2])->flip(); // collect(['1' => 'a', '2' => 'c'])
```

### `forget()`

`forget($keys)` 删除指定 `keys` 的值，`keys` 可以是数组；并返回当前数组

```php
collect(['a' => 1, 'b' => 2])->forget(['a', 'b']);

// Illuminate\Support\Collection {
//     all: [],
// }
```

### `get()`

`get($key, $default = null)` 返回集合中某个元素的值，如果不存在，可获取 `$default` 的值，`$default` 可以为回调函数

```php
collect(['a' => 1])->get('a');  // 1
collect(['a' => 1])->get('b');  // null
collect(['a' => 1])->get('b', 222);  // 222
collect(['a' => 1])->get('b', fn() => 111); // 111
```

### `groupBy()`

### `keyBy()`

### `has()`

`has($key)` 判定键是否存在，支持多个传入，必须所有满足，才能返回 `true`

```php
collect(['a' => 1, 'b' => 2, 'c' => 2])->has('a'); // true
collect(['a' => 1, 'b' => 2, 'c' => 2])->has('a', 'b'); // true
collect(['a' => 1, 'b' => 2, 'c' => 2])->has(['a', 'b']); // true
collect(['a' => 1, 'b' => 2, 'c' => 2])->has('a', 'd']); // false
```

### `implode()`

`implode($value, $glue = null)` 将集合合并为字符串

```php
collect([1, 2])->implode('##'); // 1##2
collect([['a' => 11, 'b' => 22], ['a' => 33, 'b' => 44]])->implode('a', '@@'); // 11@@33
```

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

`pluck($value, $key = null)` 返回集合中指定元素的值，`$key` 的值设置为以下标

```php
collect([['a' => 1, 'b' => 11], ['a' => 2, 'b' => 22]])->pluck('a');
// collect([1, 2]);

collect([['a' => 1, 'b' => 11], ['a' => 2, 'b' => 22]])->pluck('a', 'b');
// collect(['11' => 1, '22' => 2])
```

如果存在重复的键，则最后一个匹配元素将被插入到弹出的集合中

```php
collect([['a' => 1, 'b' => 11], ['a' => 2, 'b' => 11]])->pluck('a', 'b');
// // collect(['11' => 2])
```

### `map()`

`map(callable $callback)` 遍历集合并将值和下标，使用回调函数处理集合数据，并返回新的集合

```php
collect([['a' => 1, 'b' => 11], ['a' => 2, 'b' => 11]])->map(function ($value) {
    $value['c'] = 1;

    return $value;
});

// collect([['a' => 1, 'b' => 11, 'c' => 1], ['a' => 2, 'b' => 11, 'c' => 1]]);
```

### `mapToDictionary()`

### `mapWithKeys()`

### `merge()`

### `mergeRecursive()`

### `combine()`

### `union()`

### `nth()`

### `only()`

`only($keys)` 返回指定键的集合

```php
collect(['a' => 1, 'b' => 2, 'c' => 3])->only(['a', 'b']);
collect(['a' => 1, 'b' => 2, 'c' => 3])->only('a', 'b');
collect(['a' => 1, 'b' => 2, 'c'])->only(collect(['a', 'b']));
// 三个返回结果一致
// collect(['a' => 1, 'b' => 2])
```

### `pop()`

`pop()` 移除并返回集合中的最后一个值

```php
$collect = collect([1, 2, 3]);
$collect->pop(); // 3
$collect->all(); // [1, 2]
```

### `prepend()`

`prepend($value, $key = null)` 在集合开头插入一个值，并返回集合

```php
collect([1, 2, 3])->prepend(4); // collect([4, 1, 2, 3])
collect([1, 2, 3])->prepend(4, 'a'); // collect(['a' => 4, 1, 2, 3])
```

### `push()`

`push(...$values)` 在集合结尾插入一个或多个值

```php
collect([1, 2, 3])->push(4, 5);  // collect([1, 2, 3, 4, 5])
collect([1, 2, 3])->push(4);  // collect([1, 2, 3, 4])
```

### `concat()`

`concat($source)` 将新的集合或数组附加到当前集合结尾

```php
collect([1, 2, 3])->concat([4, 5]);  // collect([1, 2, 3, 4, 5])
collect([1, 2, 3])->concat(collect([4, 5]));  // collect([1, 2, 3, 4, 5])
```

### `pull()`

`pull($key, $default = null)` 从集合中获取并移除指定键的值，如果不存在，可获取默认值（`$default`）

```php
$collect = collect(['a' => 1, 'b' => 2]);
$collect->pull('a'); // 1
$collect->all(); // ['b' => 2]
$collect->pull('c', '3'); // 3
$collect->all(); // ['b' => 2]
```

### `put()`

`put($key, $value)` 将指定的键和值写入到集合，并返回集合；方法逻辑同 `offsetSet`，区别在于 `put()` 返回当前集合

```php
collect(['a' => 1])->put('b', 2); // collect(['a' => 1, 'b' => 2])
```

### `random()`

`random($number = null)` 随机返回一个值或指定数量值的集合（不返回键）

```php
collect([1, 2, 3, 4])->random(); // 4(每次随机)
collect([1, 2, 3, 4])->random(2); // collect([2, 3])(每次随机)
collect(['a' => 1, 'b' => 2, 'c' => 3])->random();  // 3(每次随机)
collect(['a' => 1, 'b' => 2, 'c' => 3])->random(2);  // collect([1, 2])(每次随机)
```

### `reduce()`

### `replace()`

### `replaceRecursive()`

`replaceRecursive($items)` 递归地使用参数的集合/数组的值替换当前集合的值

```php
collect(['a' => 1, 'b' => [2, 3]])->replaceRecursive(['a' => 5, 'b' => [4]]);

// collect(['a' => 5, 'b' => [4, 3]])
```

> 适合配置文件深层继承

### `reverse()`

`reverse()` 返回逆向排序集合

```php
collect(['a' => 1, 'b' => 2])->reverse();  // collect(['b' => 2, 'a' => 1])
```

### `search()`

`search($value, $strict = false)` 搜索集合中给定的值并返回下标；其中值支持回调函数；`$strict` 为是否精准匹配

```php
collect(['a' => 1, 'b' => 2])->search(1); // a
collect(['a' => 1, 'b' => 2])->search(1, true); // a
collect(['a' => 1, 'b' => 2])->search('1', true); // false
collect(['a' => 1, 'b' => 2])->search(fn($value) => $value == 1); // a
```

### `shift()`

`shift()` 从集合移除并返回第一个值

```php
collect([1, 2, 3])->shift();  // 1
```

### `shuffle()`

`shuffle($seed = null)` 将集合随机打乱，并返回新的集合；`$seed` 给随机数发生器播种。

```php
collect([1, 2, 3])->shuffle();  // collect([2, 1, 3]) 每次随机
collect([1, 2, 3])->shuffle(1);  // collect([2, 1, 3]) 每次随机
```

### `skip()`

`skip($count)` 跳过指定数量的集合，支持负数

```php
collect([1, 2, 3])->skip(1);  // collect([2, 3])
collect([1, 2, 3])->skip(-1);  // collect([3])
```

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

`take($limit)` 从集合中获取指定数量的值，支持负数

```php
collect([1, 2, 3])->take(2); // collect([1, 2])
collect([1, 2, 3])->take(-2); // collect([2, 3])
```

### `takeUntil()`

### `takeWhile()`

### `transform()`

### `values()`

`values()` 重置集合数据的下标

```php
collect(['a' => 1, 'b' => 2])->values();

// Illuminate\Support\Collection {
//     all: [
//         1,
//         2,
//     ],
// }
```

### `zip()`

### `pad()`

`pad($size, $value)` 补足指定数量的指定值到集合数据中

```php
collect([1, 2, 3])->pad(6, 123); // collect([1, 2, 3, 123, 123, 123])
```

### `getIterator()`

`getIterator()` 返回当前集合的数组迭代器

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