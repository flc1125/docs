# CDN 科普

## 一、概述

### 1.1 含义

CDN 的全称是 Content Delivery Network，即内容分发网络。CDN 是构建在网络之上的内容分发网络，依靠部署在各地的边缘服务器，通过中心平台的负载均衡、内容分发、调度等功能模块，使用户就近获取所需内容，降低网络拥塞，提高用户访问响应速度和命中率。CDN 的关键技术主要有内容存储和分发技术。 —— 摘自《[百度百科](https://baike.baidu.com/item/CDN/420951)》

![](assets/cdn-map.png)

> 名词解释：
>
> - Origin Server：源站，源服务器
> - User：访问者
> - Edge Server：CDN 的服务器

### 1.2 核心技术点

- 内容存储技术
- 内容分发技术
- 负载均衡技术

### 1.3 CDN 优势

- 加速：基于 CDN 各节点，就近获取内容
- 降低负载：基于 CDN 缓存，减少源站的访问
- 成本低：费用成本、部署成本
- 可扩展性强：基于边缘计算

## 二、原理

### 2.1 流程图

简化版流程图

![](assets/cloudfront-events.png)

> 图片来源 AWS 

相对“完整版”流程图

![](assets/flow.png)

> 图片来源 阿里云

### 2.2 缓存原理

看个 PHP 缓存的例子：

```php
<?php

$result = Cache::remember('url', 100, function () {
    return 'Hello world...';
});
```

大多数的缓存原理如上面例子，基于 URL 的维度进行 Hash 运算后生成唯一的字符，基于该字符进行缓存的获取与存储。

当涉及静态资源的更新操作的时候，更多的除了使用 URL 维度外，还会依靠附加参数的形式，进行 CDN 缓存的“更新”。但这个“更新”实际是静态资源生成新的 CDN 缓存。

!!! tip "总结"

    在实际的应用中，HTTP 请求的**任何参数**均可作为 CDN 缓存的维度，用来组合 Hash 生成唯一字符。

    这些维度包括 URL、参数、Header等。但维度的增加也同样意味着 CDN 缓存命中率的降低。


我们来看个例子：

1. https://docs.flc.io/favicon.ico
1. https://docs.flc.io/favicon.ico?v=1
1. https://docs.flc.io/favicon.ico?v=1&b=2
1. https://docs.flc.io/favicon.ico?b=2&v=1

> 以上 4 种情况，如首次访问，即使资源相同，但因为参数的原因， CDN 缓存均未命中。

### 2.3 Response Headers

大多数 CDN 服务商会在资源请求的 `Response Headers` 中输出一些涉及缓存命中、CDN 节点、Hash字符、过期时间等信息。

如图：

![](assets/header-example.png)

### 2.4 刷新预热

**刷新**（即：清理 CDN 缓存）

通过提供文件 URL 或目录的方式，强制CDN节点回源拉取最新的文件。

**预热**

将指定的内容主动预热到 CDN 的节点上，用户首次访问即可直接命中缓存，降低源站压力。

> 一般大规模迁移的时候，会使用到

### 2.5 CDN 常见功能

1. 自定义缓存过期时间规则：支持配置自定义资源的缓存过期时间规则, 支持指定路径或者文件名后缀方式, 支持 Header 输出缓存过期时间
1. 自定义 header 头：如 `Access-Control-Allow-Origin: *` 以实现跨域
1. 自定义页面：支持设置404、403、503、504等页面
1. 页面优化：去除HTML页面页面冗余内容如注释以及重复的空白符
1. 智能压缩：对静态文件类型进行压缩, 有效减少用户传输内容大小
1. 访问控制：Refer防盗链、IP 黑/白名单等
1. HTTPS 支持
1. 统计分析、日志管理
1. 人工智能服务：识图、鉴黄等

!!! question "脑回路时间"
    
    依靠第以上几点，能实现哪些应用？ :wave: :wave:

## 三、实例说明

### 3.1 静态资源加速

> 这个大家都懂，就不细说 :smile::smile:

### 3.2 后端加速（缓存）—— 自定义缓存时间

- http://cdn.flccent.com/

含 CDN 但未命中：

```php
<?php

echo 'Hello World!!!!!~';
```

设置 10s 的 CDN 缓存：

```php
<?php

header('expires: '.date('D, d M Y H:i:s e', time() + 10));

echo 'Hello World!!!!!~';
```

> 以上例子为阿里云 CDN，具体设置缓存过期时间，请参照 CDN 服务商文档进行设置。

!!! tip ""

    对于动态文件（eg：php | jsp | asp），建议设置缓存时间为 `0s`，即不缓存；若动态文件例如 php 文件内容更新频率较低，推荐设置较短缓存时间

    —— 摘自《[阿里云说明文档](https://help.aliyun.com/document_detail/27136.html?spm=5176.11785003.domainDetail.6.7d79142fpxRL9k#h2-url-2)》

**参考文档：**

- 服务器端设置过期时间：https://help.aliyun.com/knowledge_detail/40080.html?spm=a2c4g.11186623.2.12.33ad45e56FKahB

## 四、边缘计算

### 4.1 什么是边缘计算

![](assets/cloudfront-events.png)

> 图片来源 AWS 

边缘计算是指在靠近物或数据源头的一侧，采用网络、计算、存储、应用核心能力为一体的开放平台，就近提供最近端服务。其应用程序在边缘侧发起，产生更快的网络服务响应，满足行业在实时业务、应用智能、安全与隐私保护等方面的基本需求。边缘计算处于物理实体和工业连接之间，或处于物理实体的顶端。而云端计算，仍然可以访问边缘计算的历史数据。

### 4.2 实例说明：图片 WEBP 原理

关键词

- `Request Headers`: `Accept:image/webp`
- 函数计算（阿里云）、Lambda（AWS）等
- 内容存储：OSS（阿里云），S3（AWS）等 —— 可选

!!! note "大致原理"

    - 开启 CDN `Header - Accept` 回源
    - 获取 `Request Headers` 中 `Accept` 中包含 `image/webp`（即为支持webp）
    - 通过边缘计算方式，通过源站获取对应素材转换为 webp 格式，并存储至对应 CDN 节点
    - 用户通过 CDN 输出对应格式

    > 图片大多数源站均为 OSS、S3 等内容存储服务，而非具体服务器

服务说明

- [HTTP Headers Accept](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Accept)

    `Accept` 请求头用来告知客户端可以处理的内容类型，这种内容类型用 `MIME` 类型来表示。借助内容协商机制, 服务器可以从诸多备选项中选择一项进行应用，并使用 `Content-Type` 应答头通知客户端它的选择。浏览器会基于请求的上下文来为这个请求头设置合适的值，比如获取一个CSS层叠样式表时值与获取图片、视频或脚本文件时的值是不同的。

- [Lambda](https://aws.amazon.com/cn/lambda/)

    通过 AWS Lambda，无需预置或管理服务器即可运行代码。您只需按使用的计算时间付费 – 代码未运行时不产生费用。

    借助 Lambda，您几乎可以为任何类型的应用程序或后端服务运行代码，而且完全无需管理。只需上传您的代码，Lambda 会处理运行和扩展高可用性代码所需的一切工作。您可以将您的代码设置为自动从其他 AWS 产品触发，或者直接从任何 Web 或移动应用程序调用。

    !!! tip ""
        
        支持语言： `Node.js`/`Python`/`Java`/`Go`/`C#`/`PowerShell`/`Ruby`

## 五、相关文档

- 名词解释：https://help.aliyun.com/document_detail/27102.html?spm=a2c4g.11186623.6.547.49af777dDujQhC
- HTTP / 1.1头字段的语法和语义：https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html