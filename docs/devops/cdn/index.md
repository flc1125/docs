# CDN 科普

> 未完待续... :yum: :yum:

## 概述

### 含义

CDN 的全称是 Content Delivery Network，即内容分发网络。CDN 是构建在网络之上的内容分发网络，依靠部署在各地的边缘服务器，通过中心平台的负载均衡、内容分发、调度等功能模块，使用户就近获取所需内容，降低网络拥塞，提高用户访问响应速度和命中率。CDN 的关键技术主要有内容存储和分发技术。 —— 摘自《[百度百科](https://baike.baidu.com/item/CDN/420951)》

![](assets/cdn-map.png)

名词解释：

- Origin Server：源站，源服务器
- User：访问者
- Edge Server：CDN 的服务器

### 核心技术点

- 内容存储技术
- 内容分发技术
- 负载均衡技术

### CDN 优势

- 加速：基于 CDN 各节点，就近获取内容
- 降低负载：基于 CDN 缓存，减少源站的访问
- 成本低：费用成本、部署成本
- 可扩展性强：基于边缘计算

### CDN 常见功能

1. **自定义缓存过期时间规则：**支持配置自定义资源的缓存过期时间规则, 支持指定路径或者文件名后缀方式
1. 自定义 header 头：如 `Access-Control-Allow-Origin: *` 以实现跨域
1. 自定义页面：支持设置404、403、503、504等页面
1. 页面优化：去除HTML页面页面冗余内容如注释以及重复的空白符
1. 智能压缩：对静态文件类型进行压缩, 有效减少用户传输内容大小
1. 访问控制：Refer防盗链、IP 黑/白名单等

!!! question "脑回路时间"
    
    依靠第以上几点，能实现哪些应用？ :wave: :wave:

## 原理

### 流程图

### 缓存策略

### 刷新预热

**刷新**（即：清理 CDN 缓存）

通过提供文件 URL 或目录的方式，强制CDN节点回源拉取最新的文件。

**预热**

将指定的内容主动预热到 CDN 的节点上，用户首次访问即可直接命中缓存，降低源站压力。

> 一般大规模迁移的时候，会使用到

## 实例说明

### 静态资源加速

> 这个大家都懂，就不细说 :smile::smile:

### 后端加速（缓存）—— 自定义缓存时间

- http://cdn.flccent.com/logo2019.png

!!! tip ""

    对于动态文件（eg：php | jsp | asp），建议设置缓存时间为 `0s`，即不缓存；若动态文件例如 php 文件内容更新频率较低，推荐设置较短缓存时间

    —— 摘自《[阿里云说明文档](https://help.aliyun.com/document_detail/27136.html?spm=5176.11785003.domainDetail.6.7d79142fpxRL9k#h2-url-2)》

**参考文档：**

- 服务器端设置过期时间：https://help.aliyun.com/knowledge_detail/40080.html?spm=a2c4g.11186623.2.12.33ad45e56FKahB

## 边缘计算

### 什么是边缘计算

![](assets/cloudfront-events.png)

> 图片来源 AWS 

### 实例说明：图片 WEBP 原理

!!! tip "关键词"

    - `Request Headers`: `Accept:image/webp`
    - 函数计算（阿里云）、Lambda（AWS）等
    - 内容存储：OSS（阿里云），S3（AWS）等 —— 可选

大致原理：

- 开启 CDN `Header - Accept` 回源
- 获取 `Request Headers` 中 `Accept` 中包含 `image/webp`（即为支持webp）
- 通过边缘计算方式，通过源站获取对应素材转换为 webp 格式，并存储至对应 CDN 节点
- 用户通过 CDN 输出对应格式

> 图片大多数源站均为 OSS、S3 等内容存储服务，而非具体服务器


## 其他

### 其他应用

- AWS：Lambda