# 安装

Elasticsearch-php 的安装需要满足以下 4 个需求：

- PHP 7.0.0 或更高版本
- [Composer](https://www.phpcomposer.com/)
- [ext-curl](http://php.net/manual/zh/book.curl.php)：PHP 的 Libcurl 扩展（详情查看下方注意事项）
- 原生 JSON 扩展 (`ext-json`) 1.3.7或更高版本

其余的依赖会由 Composer 自动安装。Composer 是一个 PHP 包管理和依赖管理工具，使用 Composer 安装 elasticsearch-php 非常简单。

!!! note "Libcurl 是可替代的"
    与 Elasticsearch-php 客户端绑定的默认 HTTP handlers 需要 PHP 的 Libcurl 扩展，但客户端也并非一定要用 Libcurl 扩展。如果你有 一台主机没有安装 Libcurl 扩展，你可以使用基于 PHP streams 的 HTTP handler 来替代。但是性能会变差，因为 Libcurl 扩展要快得多。

## 版本矩阵

Elasticsearch-PHP 的版本要和 Elasticsearch 版本适配。

Elasticsearch-PHP 的 master 分支总是与 Elasticsearch 的 master 分支相一致，但不建议在生产环境代码中使用 dev-master 分支。

|Elasticsearch Version  | Elasticsearch-PHP Branch|
|-------                | --------                |
| >= 6.0                | `6.0`                   |
| >= 5.0, <= 6.0        | `5.0`                   |
| >= 1.0, <= 5.0        | `1.0`, `2.0`            |
| <= 0.90.*             | `0.4`                   |

## Composer 安装

- 在 `composer.json` 文件中增加 elasticsearch-php。如果你是新建项目，那么把以下的代码复制粘贴到 `composer.json` 就行了。如果是在现有项目中添加 elasticsearch-php，那么把 elasticsearch-php 添加到其它的包名后面即可：

    ```json
    {
        "require": {
            "elasticsearch/elasticsearch": "~6.0"
        }
    }
    ```

- 使用 composer 安装客户端：首先要用下面第一个命令来安装 `composer.phar` ，然后使用第二个命令来执行安装程序。composer 会自动下载所有的依赖，把下载的依赖存储在 `/vendor/` 目录下，并且创建一个 `autoloader`：

    ```bash
    curl -s http://getcomposer.org/installer | php
    php composer.phar install --no-dev
    ```

    关于 Composer 的详情请查看[Composer 中文网](https://www.phpcomposer.com/)。

- 最后加载 autoload.php。如果你现有项目是用 Composer 安装的，那么 autoload.php 也许已经在某处加载了，你就不必再加载。最后实例化一个客户端对象：

    ```php
    <?php
    require 'vendor/autoload.php';

    $client = Elasticsearch\ClientBuilder::create()->build();
    ```
    
    客户端对象的实例化主要是使用静态方法 `create()` ，这里会创建一个 `ClientBuilder` 对象，主要是用来设置一些自定义配置。如果你配置完了，你就可以调用 `build()` 方法来创建一个 `Client` 对象。我们会在配置一节中详细说明配置方法。



## --no-dev标志

你会注意到安装命令行指定了 `--no-dev` 。这里是防止 Composer 安装各种测试依赖包和开发依赖包。对于普通用户没有必要安装测试包。特别是开发依赖包包含了 Elasticsearch 的一套源码，这是为了以 REST API 的方式进行测试。然而这对于非开发者来说太大了，因此要使用 `--no-dev`。

如果你想帮助完善这个客户端类库，那就删掉 `--no-dev` 标志来进行测试吧。
