# 建造者模式（Builder）

> 原文：https://laravel-china.org/docs/php-design-patterns/2018/Builder/1488

## 1. 目的

建造者是创建一个复杂对象的一部分接口。

有时候，如果建造者对他所创建的东西拥有较好的知识储备，这个接口就可能成为一个有默认方法的抽象类（又称为适配器）。

如果对象有复杂的继承树，那么对于建造者来说，有一个复杂继承树也是符合逻辑的。

注意：建造者通常有一个「[流式接口](https://zh.wikipedia.org/wiki/%E6%B5%81%E5%BC%8F%E6%8E%A5%E5%8F%A3)」，例如 PHPUnit 模拟生成器。