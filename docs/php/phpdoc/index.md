# PHPDoc 代码注释

[TOC]

## 规范注释

**标准注释**

```php
/**
 * 标题及说明
 *
 * @author 作者 <邮箱>
 * @param  参数数据类型 参数变量 参数说明
 *
 * @return 返回数据类型 返回说明
 */
```

> 注： 其中前端应用中`参数数据类型`，為区分参数变量，会加上`{}`，如：`{参数数据类型}`

**例子**

```php
/**
 * 加法计算
 *
 * @author 作者 <邮箱>
 * @param  number $m 参数1
 * @param  number $n 参数2
 *
 * @return number
 */
function calc($m, $n)
{
    return $m + $n;
}
```

## 数据类型

|标识|说明|
|----|----|
|`integer` 或 `int`|整数类型|
|`boolean` 或 `bool`|布尔值类型|
|`number`|数字|
|`string`|字符串|
|`array`|数组|
|`object`|对象|
|`mixed`|混合类型|
|`void`|空类型|

## 文档标记

- 文档标记的使用范围是指该标记可以用来修饰的关键字，或其他文档标记。
- 所有的文档标记都是在每一行的 `*` 后面以`@`开头。如果在一段话的中间出来@的标记，这个标记将会被当做普通内容而被忽略掉。

```php
/**
 * @name 名字
 * @abstract 申明变量/类/方法
 * @access 指明这个变量、类、函数/方法的存取权限
 * @author 函数作者的名字和邮箱地址
 * @category 组织packages
 * @copyright 指明版权信息
 * @const 指明常量
 * @deprecate 指明不推荐或者是废弃的信息
 * @example 示例
 * @exclude 指明当前的注释将不进行分析，不出现在文挡中
 * @final 指明这是一个最终的类、方法、属性，禁止派生、修改。
 * @global 指明在此函数中引用的全局变量
 * @include 指明包含的文件的信息
 * @link 定义在线连接
 * @module 定义归属的模块信息
 * @modulegroup 定义归属的模块组
 * @package 定义归属的包的信息
 * @param 定义函数或者方法的参数信息
 * @return 定义函数或者方法的返回信息
 * @see 定义需要参考的函数、变量，并加入相应的超级连接。
 * @since 指明该api函数或者方法是从哪个版本开始引入的
 * @static 指明变量、类、函数是静态的。
 * @throws 指明此函数可能抛出的错误异常,极其发生的情况
 * @todo 指明应该改进或没有实现的地方
 * @var 定义说明变量/属性。
 * @version 定义版本信息
 */
```

- `@access`
    使用范围：`class`,`function`,`var`,`define`,`module`
    
    该标记用于指明关键字的存取权限：`private`、`public`或`proteced`

- `@author`
    指明作者

- `@copyright`
    使用范围：`class`，`function`，`var`，`define`，`module`，`use`
    
    指明版权信息

- `@deprecated`
    使用范围：`class`，`function`，`var`，`define`，`module`，`constent`，`global`，`include`
    指明不用或者废弃的关键字

- `@example`
    该标记用于解析一段文件内容，并将他们高亮显示。Phpdoc会试图从该标记给的文件路径中读取文件内容

- `@const`
    使用范围：`define`
    
    用来指明php中define的常量

- `@final`
    使用范围：`class`,`function`,`var`
    
    指明关键字是一个最终的类、方法、属性，禁止派生、修改。

- `@filesource`
    和example类似，只不过该标记将直接读取当前解析的php文件的内容并显示。

- `@global`
    指明在此函数中引用的全局变量

- `@ingore`
    用于在文档中忽略指定的关键字

- `@license`
    许可权

- `@link`
    类似于`license`；但还可以通过link指到文档中的任何一个关键字

- `@name`
    为关键字指定一个别名。

- `@package`
    使用范围：页面级别的-> `define`，`function`，`include`
    
    类级别的->`class`，`var`，`methods`
    
    用于逻辑上将一个或几个关键字分到一组。

- `@abstrcut`
    说明当前类是一个抽象类

- `@param`
    指明一个函数的参数

- `@return`
    指明一个方法或函数的返回指

- `@static`
    指明关建字是静态的。

- `@var`
    指明变量类型

- `@version`
    指明版本信息

- `@todo`
    指明应该改进或没有实现的地方

- `@throws`
    指明此函数可能抛出的错误异常,极其发生的情况
    
    上面提到过，普通的文档标记标记必须在每行的开头以@标记，除此之外，还有一种标记叫做inline tag,用{@}表示，具体包括以下几种：

- `{@link}`
    用法同`@link`

- `{@source}`
    显示一段函数或方法的内容
