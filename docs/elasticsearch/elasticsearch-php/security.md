# 安全

Elasticsearch-PHP 客户端支持两种安全设置方式：HTTP 认证和 SSL 加密。

## HTTP 认证

如果你的 Elasticsearch 是通过 HTTP 认证来维持安全，你就要为 Elasticsearch-PHP 客户端提供身份凭证（credentials），这样服务端才能认证客户端请求。在实例化客户端时，身份凭证（credentials）需要配置在 host 数组中：

```php
<?php
$hosts = [
    'http://user:pass@localhost:9200',       // HTTP Basic Authentication
    'http://user2:pass2@other-host.com:9200' // Different credentials on different host
];

$client = ClientBuilder::create()
                    ->setHosts($hosts)
                    ->build();
```

每个 host 都要添加身份凭证（credentials），这样的话每个 host 都拥有自己的身份凭证（credentials）。所有发送到集群中的请求都会根据访问节点来使用相应的身份凭证（credentials）。

## SSL 加密

配置 SSL 会有些复杂。你要去识别 Certificate Authority (CA) 签名的证书或者自签名证书。

!!! note "libcurl版本注意事项"

    如果你觉得客户端已经正确配置 SSL，但是没有起效，请检查你的 libcurl 版本。在某些平台上，一些设置可能有效也可能无效，这取决于 libcurl 版本号。例如直到 libcurl 7.37.1，OSX 平台的 libcurl 才添加 `--cacert` 选项。 `--cacert` 选项对应 PHP 的 `CURLOPT_CAINFO` 常量，这就意味着自定义的证书在低版本下是无法使用的。
    
    如果你现在正面临这个问题，请更新你的 libcurl，然后/或者查看 [curl changelog](https://curl.haxx.se/changes.html) 有无增加该选项。

### 公共 CA 证书

如果你的证书是公共 CA 签名证书，且你的服务器用的是最新的根证书，你只需要在 host 中使用 https。客户端会自动识别 SSL 证书：

```php
<?php
$hosts = [
    'https://localhost:9200' <1>
];

$client = ClientBuilder::create()
                    ->setHosts($hosts)
                    ->build();
```

- <1> 注意：这里用的是 https 而非 http

如果服务器的根证书已经过期，你就要用证书 bundle。对于客户端来说，最好的方法是使用 [composer/ca-bundle](https://github.com/composer/ca-bundle)。一旦安装好 ca-bundle，你要告诉客户端使用你提供的证书来替代系统的 bundle：

```php
<?php
$hosts = ['https://localhost:9200'];
$caBundle = \Composer\CaBundle\CaBundle::getBundledCaBundlePath();

$client = ClientBuilder::create()
                    ->setHosts($hosts)
                    ->setSSLVerification($caBundle)
                    ->build();
```

### 自签名证书

自签名证书是指没有被公共 CA 签名的证书。自签名证书由你自己的组织来签名。在你确保安全发送自己的根证书前提下，自签名证书可用作内部使用的。当自签名证书暴露给公众客户时就不应该使用了，因为客户端容易受到中间人攻击。

如果你正使用自签名证书，你要给客户端提供证书路径。这与指定一个根 bundle 的语法一致，只是把根 bundle 替换为自签名证书：

```php
<?php
$hosts = ['https://localhost:9200'];
$myCert = 'path/to/cacert.pem';

$client = ClientBuilder::create()
                    ->setHosts($hosts)
                    ->setSSLVerification($myCert)
                    ->build();
```

## 同时使用认证与  SSL

同时使用认证与 SSL 也是有可能的。在 URI 中指定 `https` 与身份凭证（credentials），同时提供 SSL 所需的自签名证书。例如下面的代码段就同时使用了 HTTP 认证和自签名证书：

```php
<?php
$hosts = ['https://user:pass@localhost:9200'];
$myCert = 'path/to/cacert.pem';

$client = ClientBuilder::create()
                    ->setHosts($hosts)
                    ->setSSLVerification($myCert)
                    ->build();
```