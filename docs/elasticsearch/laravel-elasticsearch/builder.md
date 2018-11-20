# 查询构造器

## 指定 index

```php
<?php

Elasticsearch::index('users');
```

> `index()`方法中的值为字符串时候，即调用本扩展的查询构造器。否则为官方扩展 `elasticsearch/elasticsearch` 的语法

## 指定 type

```php
<?php

Elasticsearch::index('users')->type('_doc');
```

> 根据官方的描述，`type` 后续版本会弃用，建议在使用中，弱化此参数。

## 指定字段

```php
<?php

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
<?php

Elasticsearch::index('users')->where('age', '=', 10)->get();
```

当操作/运算符为 `=` 时，我们也可以简写为：

```php
<?php

Elasticsearch::index('users')->where('age', 10)->get();
```

如果你想指定符合查询的构造类型也可以使用第四个参数：

```php
<?php

// 获取 age = 10 并使用 must
Elasticsearch::index('users')->where('age', '=', 10, 'must')->get();

// 获取 age != 10，即使用 must_not 即可
Elasticsearch::index('users')->where('age', '=', 10, 'must_not')->get();
// 当然 age != 10 也等同于下面写法
Elasticsearch::index('users')->where('age', '!=', 10)->get();
```

当然，不仅仅支持 `=` 的操作/运算符，我们还支持很多其他的操作/运算符，他们有：`>`、`<`、`>=`、`<=`、`!=`、`<>`、`match`、`not match`、`like`、`not like`。

```php
<?php

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
<?php

// 获取 status = 1 和 closed = 0
Elasticsearch::index('users')->where([
    'status' => 1,
    'closed' => 0,
])->get();
```

也可以：

```php
<?php

// 获取 status = 1 和 closed = 0 （其中 closed 使用 must）
Elasticsearch::index('users')->where([
    ['status', 1],
    ['closed', '=', 1, 'must']
])->get();
```

### orWhere

### whereIn / orWhereIn / whereNotIn

### whereTerm / whereTerms

### whereMatch / whereMatchPhrase

### whereRange / whereBetween

### whereExists / whereNotExists / whereNull

### 

## orderBy 排序

`orderBy` 方法允许你通过给定字段对结果集进行排序。`orderBy` 的第一个参数是排序的字段，第二个参数是排序的方向，可以是 `asc`(默认) 或 `desc`。等同于 Elasticsearch 的 `sort`

```php
<?php

Elasticsearch::index('users')->orderBy('id', 'asc')->first();

Elasticsearch::index('users')->orderBy('id', 'asc')->orderBy('username', 'desc')->first();
```

## skip / take

要限制结果的返回数量，或跳过指定数量的结果，你可以使用 `skip` 和 `take` 方法，等同于 Elasticsearch 的 `from` 和 `size`，范例如下：

```php
<?php

Elasticsearch::index('users')->skip(10)->size(20)->first();
```

或者使用 `offset` 和 `limit` 代替

```php
<?php

Elasticsearch::index('users')->offset(10)->limit(20)->first();
```

## 分页

### 分页数据查询

`forPage` 方法是分页数据查询，它允许你按每页多少数量，去查询指定页的数据。`forPage` 的第一个参数是指定页数，第二个参数是每页的数据量（默认为 15），范例如下：

```php
<?php

Elasticsearch::index('users')->forPage(2, 15)->get();
```

### 简单分页

`simplePaginator` 待定

### paginate 分页

```php
<?php

Elasticsearch::index('users')->paginate();
```

> 等同于 laravel 的 `Model` 或 `DB` 分页