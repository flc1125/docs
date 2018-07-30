# 快速开始编辑

这一节会概述一下客户端以及客户端的一些主要方法的使用规则。

## 安装

- 在 composer.json 文件中引入 elasticsearch-php：

    ```json
    {
        "require": {
            "elasticsearch/elasticsearch": "~6.0"
        }
    }
    ```

- 用 composer 安装客户端：

    ```bash
    curl -s http://getcomposer.org/installer | php
    php composer.phar install --no-dev
    ```
    
- 在项目中引入自动加载文件（如果还没引入），并且实例化一个客户端：

    ```php
    require 'vendor/autoload.php';

    use Elasticsearch\ClientBuilder;

    $client = ClientBuilder::create()->build();
    ```