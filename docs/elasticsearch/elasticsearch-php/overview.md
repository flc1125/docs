# 概述

!!! Tip "转载说明"
    内容来源：《[官方 Elasticsearch-PHP](https://www.elastic.co/guide/cn/elasticsearch/php/current/index.html)》

这是 Elasticsearch 官方的 PHP 客户端。我们把 Elasticsearch-PHP 设计成低级客户端（[低级设计模式](https://en.wikipedia.org/wiki/Low-level_design)），使用时不会偏离 REST API 的用法。

客户端所有方法几乎都与 REST API 对应，而且也与其他编程语言的客户端（如 ruby, python 等）方法结构相似。我们希望这种对应方式可以方便开发者更加容易上手客户端，且以最小的代价快速从一种编程语言转换到另一种编程语言。

本客户端设计得很“灵活”。虽然有一些通用的细节添加进了客户端（集群状态嗅探，轮询调度请求等），但总的来说它是十分基础的。这也是有意这样设计。我们只是设计了基础方法，更多的复杂类库可以在此衍生出来。

## 鸣谢

感谢 [@Mosongxing](https://github.com/mosongxing) 贡献本手册的中文翻译。
