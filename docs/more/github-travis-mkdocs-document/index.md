# Github + Travis + Mkdocs 搭建文档库

## 1. 概述

想搭建一个免费的文档库吗？想搭建一个跟本站点一样的文档库吗？

> 路人甲：不想... 别看了，以下都是吹牛逼的... :mask: :mask:

### 1.1. 要求

- 了解 Python
- 有 Github 账号
- 熟悉 [Markdown](http://wow.kuapp.com/markdown/) 语法

### 1.2. 介绍

**Github：** 全球最大同性交友网站 :sweat_smile: :sweat_smile:

> GitHub is a development platform inspired by the way you work. From open source to business, you can host and review code, manage projects, and build software alongside 28 million developers.

**Travis：** 持续集成服务（Continuous Integration，简称 CI）

> **Test and Deploy with Confidence**  
> Easily sync your GitHub projects with Travis CI and you’ll be testing your code in minutes!

**Mkdocs：** 基于 Python 的开源文档库生成器

> MkDocs is a fast, simple and downright gorgeous static site generator that's geared towards building project documentation. Documentation source files are written in Markdown, and configured with a single YAML configuration file.

## 2. Mkdocs

### 2.1. 安装

```sh
pip install mkdocs
```

> 需安装Python，支持的版本：2.7、3.4、3.5、3.6、3.7

### 2.2. 创建文档库

```sh
mkdocs new my-docs # mkdocs new [项目目录]
```

### 2.3. 启用内置服务

```sh
# 启用服务，http://127.0.0.1:8000
mkdocs serve

# 指定IP 端口
mkdocs serve -a 0.0.0.0:8000 # mkdocs serve -a [ip:port]
```

> 支持编辑保存，自动编译渲染

### 2.4. 编译构建站点

```sh
mkdocs build
```

### 2.5. Github Pages

自动编译发布至 Github `gh-pages` 分支

```sh
mkdocs gh-deploy
```

## 3. Github

### 3.1. 版本库

创建仓库，提交代码。

> 注意忽略 `site` 目录

### 3.2. 申请 Token

- 访问地址：https://github.com/settings/tokens
- 点击右侧 `Generate new token` 按钮
- `Token description` 输入 Token 描述，随意
- 勾选权限 `Select scopes` 下的 `repo` 下所有
- 点击生成，将生成的 `token` 留好备用

**操作演示**

![](assets/github-token.gif)

## 4. Travis

### 4.1. Travis 设置

- 进入集成服务列表： https://travis-ci.org/account/repositories

    > PS: 如项目不存在，点击左侧的 `Sync account` 按钮。

- 找到对应的仓库，点击右侧的开关，开启服务
- 点击右侧 `Settings` 进入设置界面
- 在 `Settings` 栏位下 `Environment Variables` 下新增环境变量名和对应值：
    
    |环境变量名|环境变量值|
    |----|----|
    |`GITHUB_TOKEN`|`980ff900b07d3efc78e1a6eaa1becb49ea5c9cab`|
    
    > 环境变量值为上步骤生成的 `Token`  
    > PS: 注意禁用右侧的`Display value in build log` 选项，避免敏感信息暴露在构建日志中

**相关操作如图**

![](assets/legacy-services.png)

### 4.2. 配置 `.travis.yml`

仓库根目录创建文件 `.travis.yml`, 内容如下：

```yaml
language: python

python:
  - "3.6"

install:
  - pip install mkdocs
  - echo -e "machine github.com\n  login ${GITHUB_TOKEN}" > ~/.netrc

script:
  - mkdocs gh-deploy --force --clean

branches:
  only:
    - master
```

## 5. 附录

### 5.1. Github Pages 自定义域名

- 文档根目录新增文件：`CNAME`，内填写对应域名即可，[参考文档](https://help.github.com/articles/setting-up-a-custom-subdomain/)
- 域名解析，通过添加 `CNAME` 类型，指向到 Github，[参考文档](https://help.github.com/articles/quick-start-setting-up-a-custom-domain/)

> Github Pages 会自动识别 `CNAME` 绑定域名（还提供免费的 HTTPS 服务 :smile: :smile:)

### 5.2. 百度收录问题

因依靠 Github Pages 服务提供 WEB 服务。而 Github Pages 服务对百度做了屏蔽处理，以至于百度无法收录（*谷歌正常*）。如介意，可使用**云存储**或自搭服务器方式存储。

!!! note "参考"

    https://docs.flc.io 使用的是 [又拍云](https://www.upyun.com/) 云存储， 服务接近免费，支持 CDN，WEBP 等。还有免费的 HTTPS 证书申请。(不是广告 :joy: :joy:)  
    对应 [构建配置参考](https://github.com/flc1125/docs/blob/eb7d7b6610b52895ba84ca51c24b1569a4c3e719/.travis.yml)

    > 类似这样的**云存储**，还有阿里云 OSS，亚马逊 S3，腾讯云 COS，七牛云等

### 5.3. 主题：`Material`

https://docs.flc.io 使用的开源主题 [Material](https://squidfunk.github.io/mkdocs-material/)，如何使用，请参考官网。

> 感受：美观、响应式、扩展丰富

## 6. 结语

本方案提供的是一个实现 **自动化集成发布 & 免费的 WEB 服务** 思路。而基于该方案，可衍生出更多的服务，如 [Hexo](https://hexo.io/) 等第三方框架的自动化搭建，自动化测试等。

## 7. 参考

- Mkdocs 官网：https://www.mkdocs.org/
- Material 主题：https://squidfunk.github.io/mkdocs-material/
- Github： https://github.com
- Travis: https://travis-ci.org
- Python: https://www.python.org/
- Travis git 权限问题：https://notes.iissnan.com/2016/publishing-github-pages-with-travis-ci/
- Netlify WEB 项目平台（构建、部署、管理） : https://www.netlify.com/   *—— Github 官方博客有推荐*