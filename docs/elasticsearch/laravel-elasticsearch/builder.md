# 查询构造器

## 指定 connection

```php
Elasticsearch::connection('node2');
```

> 默认连接： `config/elasticsearch.php` 中 `default` 对应的连接。

## 指定 index

```php
Elasticsearch::index('users');

Elasticsearch::index('user*');
```

!!! tip ""

    **注：** `index()`方法中的值为字符串时，即调用本扩展的查询构造器。否则为官方扩展 `elasticsearch/elasticsearch` 的语法。

## 指定 type

```php
Elasticsearch::index('users')->type('_doc');

Elasticsearch::index('users')->type('*doc');
```

!!! tip ""

    根据官方的描述，`type` 后续版本会弃用，建议在使用中，弱化此参数。

## 指定字段

```php
Elasticsearch::index('users')->select('id', 'username')->first();

Elasticsearch::index('users')->select(['id', 'username'])->get();

Elasticsearch::index('users')->where('id', 1)->get(['id', 'username']);
```

## Where 查询

!!! warning ""

    因 Elasticsearch 的分值特性（`_score`)，`bool` 的复合查询，在不同的构造语句下(如`must`,`filter`,`must_not`,`should`)，会影响分值的计算。SO： 扩展中的 `where` 系列的方法查询中，为兼容此特性，除特殊方法外，均增加参数便于分值计算。

    > **注：** 在无特定的方法下，默认的构造类型为 `filter`。

### where

`where` 方法是应用中最常用的查询构造方法。`where` 总共有四个参数。第一个参数需要查询的字段，第二个参数是操作/运算符，第三个参数是指定的值，第四个参数为复合查询的构造类型。

#### 简单使用

我们先看个简单的例子，查询 `age` 等于 10 的数据：

```php
Elasticsearch::index('users')->where('age', '=', 10)->get();
```

当操作/运算符为 `=` 时，我们也可以简写为：

```php
Elasticsearch::index('users')->where('age', 10)->get();
```

如果你想指定符合查询的构造类型也可以使用第四个参数：

```php
// 获取 age = 10 并使用 must
Elasticsearch::index('users')->where('age', '=', 10, 'must')->get();

// 获取 age != 10，即使用 must_not 即可
Elasticsearch::index('users')->where('age', '=', 10, 'must_not')->get();

// 当然 age != 10 也等同于下面写法
Elasticsearch::index('users')->where('age', '!=', 10)->get();
```

当然，不仅仅支持 `=` 的操作/运算符，我们还支持很多其他的操作/运算符，他们有：`>`、`<`、`>=`、`<=`、`!=`、`<>`、`match`、`not match`、`like`、`not like`。

```php
// 获取 age >= 10
Elasticsearch::index('users')->where('age', '>=', 10)->get();

// 获取 username 含 “张”，等同于 Elasticsearch 的 match
Elasticsearch::index('users')->where('username', 'match', '张')->get();

// 获取 username 含 “张三” 短语，等同于 Elasticsearch 的 match_phrase
Elasticsearch::index('users')->where('username', 'like', '张')->get();
```

!!! warning ""

    **注：** 使用 `like` / `not like` 操作/运算符时，无需在匹配中增加 `%` 符号

#### 高阶使用

多个条件进行匹配的时候，我们可以：

```php
// 获取 status = 1 和 closed = 0
Elasticsearch::index('users')->where(['status' => 1, 'closed' => 0])->get();
```

也可以：

```php
// 获取 status = 1 和 closed = 0 （其中 closed 使用 must）
Elasticsearch::index('users')->where([
    ['status', 1],
    ['closed', '=', 1, 'must']
])->get();
```

还可以使用匿名方法，进行无限级 bool 嵌套：

```php
// 获取 status = 1 和 closed = 0 
Elasticsearch::index('users')->where(function ($query) {
    $query->where('status', 1)
        ->where('closed', 0);
})->get();
```

### orWhere

`orWhere` 方法为或查询。它作用基本为 `where($column, $operator, $value, 'should')`的变种（即：第四个参数为 `should`)：

```php
Elasticsearch::index('users')->orWhere('status', 1)->get();

Elasticsearch::index('users')->orWhere(['status' => 1, 'closed' => 1])->get();
```

### whereIn / orWhereIn / whereNotIn

`whereIn` 方法为查询指定数组内的值。它总共有三个参数：第一个参数是字段名；第二个是数组值，第三个是构造类型。

```php
Elasticsearch::index('users')->whereIn('status', [1, 2])->get();

Elasticsearch::index('users')->whereIn('status', [1, 2], 'must')->get();

Elasticsearch::index('users')->whereIn('status', [1, 2], 'must_not')->get();

Elasticsearch::index('users')->whereIn('status', [1, 2], 'should')->get();
```

`orWhereIn / whereNotIn` 方法分别是或查询和不在数组内的值。

```php
// 等同：whereIn('status', [1, 2], 'should')
Elasticsearch::index('users')->orWhereIn('status', [1, 2])->get();

// 等同：whereIn('status', [1, 2], 'must_not')
Elasticsearch::index('users')->whereNotIn('status', [1, 2])->get();
```

### whereTerm / whereTerms

`whereTerm / whereTerms` 方法分别是 Elasticsearch 的 `Term / Terms` 构造方法。

```php
Elasticsearch::index('users')->whereTerm('status', 1)->get();

Elasticsearch::index('users')->whereTerms('status', [1, 2])->get();

Elasticsearch::index('users')->whereTerm('status', 1, 'must')->get();
```

### whereMatch / whereMatchPhrase

`whereMatch / whereMatchPhrase` 方法分别是 Elasticsearch 的 `match / match_phrase` 构造方法。

```php
Elasticsearch::index('users')->whereMatch('name', '张三')->get();

Elasticsearch::index('users')->whereMatchPhrase('name', '张三')->get();

Elasticsearch::index('users')->whereMatch('name', '张三', 'must')->get();
```

### whereRange / whereBetween

`whereRange` 方法分别是 Elasticsearch 的 `range` 构造方法。

```php
Elasticsearch::index('users')->whereRange('age', '>', 3)->get();

Elasticsearch::index('users')->whereRange('age', '<', 3)->get();

Elasticsearch::index('users')->whereRange('age', '>=', 3)->get();

Elasticsearch::index('users')->whereRange('age', '<=', 3)->get();

Elasticsearch::index('users')->whereRange('age', '<=', 3, 'must')->get();
```

当然，针对区间的，你也可以使用 `whereBetween` 方法：

```php
// >= 3 and <= 6
Elasticsearch::index('users')->whereBetween('age', [3, 6])->get();

Elasticsearch::index('users')->whereBetween('age', [3, 6], 'must')->get();
```

### addWhere

如果以上的 `where` 都没有你想要的，那你也可以使用 `addWhere` 方法添加原生的条件查询：

```php
Elasticsearch::index('users')->addWhere([
    'term' => [
        "status" => [
            "value" => 3,
            'boost' => 2,
        ]
    ]
])->get();

Elasticsearch::index('users')->addWhere([
    'term' => [
        "status" => [
            "value" => 3,
            'boost' => 2,
        ]
    ]
], 'must')->get();
```

## orderBy / addOrder 排序

`orderBy` 方法允许你通过给定字段对结果集进行排序。`orderBy` 的第一个参数是排序的字段，第二个参数是排序的方向，可以是 `asc`(默认) 或 `desc`。等同于 Elasticsearch 的 `sort`

```php
Elasticsearch::index('users')->orderBy('id', 'asc')->first();

Elasticsearch::index('users')->orderBy('id', 'asc')->orderBy('username', 'desc')->first();
```

如果 `orderBy` 满足不了你的排序，也可以使用 `addOrder` 方法，增加原生的排序方法：

```php
Elasticsearch::index('users')->addOrder([
    '_script' => [
        'type'   => 'number',
        'script' => [
            'source' => 'doc["age"].value + doc["sex"].value',
        ],
        'order' => 'desc',
    ],
])->first();
```

## skip / take

要限制结果的返回数量，或跳过指定数量的结果，你可以使用 `skip` 和 `take` 方法，等同于 Elasticsearch 的 `from` 和 `size`，范例如下：

```php
Elasticsearch::index('users')->skip(10)->take(20)->first();
```

或者使用 `offset` 和 `limit` 代替

```php
Elasticsearch::index('users')->offset(10)->limit(20)->first();
```

## 分页

### 分页数据查询

`forPage` 方法是分页数据查询，它允许你按每页多少数量，去查询指定页的数据。`forPage` 的第一个参数是指定页数，第二个参数是每页的数据量（默认为 15），范例如下：

```php
Elasticsearch::index('users')->forPage(2, 15)->get();
```

### 简单分页

`simplePaginator` 待定

### paginate 分页

```php
Elasticsearch::index('users')->paginate(20);
```

> 等同于 laravel 的 `Model` 或 `DB` 分页

## toSearch / toBody

`toSearch` 方法是用于查看 Elasticsearch-PHP 用于查询的原始参数：

```php tab="Code"
$res = Elasticsearch::index('users')
    ->select('id', 'username', 'password', 'created_at', 'updated_at', 'status', 'deleted')
    ->whereTerm('status', 1)
    ->orderBy('id', 'desc')
    ->take(2)
    ->toSearch();

print_r($res);
```

``` tab="Result"
Array
(
    [index] => users
    [_source] => Array
        (
            [0] => id
            [1] => username
            [2] => password
            [3] => created_at
            [4] => updated_at
            [5] => status
            [6] => deleted
        )

    [size] => 2
    [body] => Array
        (
            [sort] => Array
                (
                    [0] => Array
                        (
                            [id] => desc
                        )

                )

            [query] => Array
                (
                    [bool] => Array
                        (
                            [filter] => Array
                                (
                                    [0] => Array
                                        (
                                            [term] => Array
                                                (
                                                    [status] => 1
                                                )

                                        )

                                )

                        )

                )

        )

)
```

`toBody` 方法是用于查看 Elasticsearch-PHP 用于查询的 `body` 参数：

```php tab="Code"
$res = Elasticsearch::index('users')
    ->select('id', 'username', 'password', 'created_at', 'updated_at', 'status', 'deleted')
    ->whereTerm('status', 1)
    ->orderBy('id', 'desc')
    ->take(2)
    ->toBody();

print_r($res);
```

``` tab="Result"
Array
(
    [sort] => Array
        (
            [0] => Array
                (
                    [id] => desc
                )

        )

    [query] => Array
        (
            [bool] => Array
                (
                    [filter] => Array
                        (
                            [0] => Array
                                (
                                    [term] => Array
                                        (
                                            [status] => 1
                                        )

                                )

                        )

                )

        )

)
```