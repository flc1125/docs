# 序列化器

客户端有 3 种序列化器可用。你可能永远都不会更改序列化器，除非你有特殊需求或者要实现一个新的协议。

序列化器的工作是 encode 发送的请求体和 decode 返回的响应体。在 99% 的例子中，这就是一种简单转换为JSON数据或解析 JSON 数据的工具。

默认的序列化器是 `SmartSerializer` 。

## SmartSerializer

### Serialize()

`SmartSerializer` 会先检查需要 encode 的数据。如果请求体是字符串，那么会直接发送到 Elasticsearch。这种方式允许用户提供原生JSON数据，或是字符串（提供给某些没有结构的 endpoint，例如 Analyze endpoint）。

如果数据是数组，则会被转换为 JSON 数据。如果数据是空数组，那么序列化器需要手动转换空数组（ `[]` ）为空对象（ `{}` ），这样发送给 Elasticsearch 的请求体数据才是有效的 JSON 数据。

### Deserialize()

当 decode 响应体数据时， `SmartSerializer` 会检测响应头的 `content_type` 来判断是否为合适的encode数据。假如数据 encode 为 JSON 数据，那么会用 `json_decode` 来解析 JSON 数据为数组。否则会以字符串的格式返回给客户端。

这个功能需要与 endpoint 协作，例如 `Cat` endpoints 会返回表格文本而非 JSON 数据。

### 选择 SmartSerializer

客户端默认选择 `SmartSerializer` ，但如果你想手动地配置这个选择器，你可以在 ClientBuilder 对象中使用 `setSerializer()` 方法：

```php
<?php
$client = ClientBuilder::create()
            ->setSerializer('\Elasticsearch\Serializers\SmartSerializer');
            ->build();
```

注意：要通过命名空间加类名的方法来配置序列化器。

## ArrayToJSONSerializer

### Serialize()

`ArrayToJSONSerializer` 会先检查需要 encode 的数据。如果请求体是字符串，那么会直接发送到 Elasticsearch。这种方式允许用户提供原生 JSON 数据，或是字符串（提供给某些没有结构的 endpoint，例如 Analyze endpoint）。

如果数据是数组，则会被转换为 JSON 数据。如果数据是空数组，那么序列化器需要手动转换空数组（ `[]` ）为空对象（ `{}` ），这样发送给 Elasticsearch 的请求体数据才是有效的 JSON 数据。

### Deserialize()

当 decode 响应体数据时，所有数据都会 encode 由 JSON 数据 decode 为 JSON 数据。如果数据不是有效的 JSON 数据，那么会返回 `null` 给客户端。

### 选择 ArrayToJSONSerializer

你可以通过使用 ClientBuilder 对象的 `setSerializer()` 方法来选择 `ArrayToJSONSerializer` ：

```php
<?php
$client = ClientBuilder::create()
            ->setSerializer('\Elasticsearch\Serializers\ArrayToJSONSerializer');
            ->build();
```

注意：要通过命名空间加类名的方法来配置序列化器。

## EverythingToJSONSerializer

### Serialize()

`EverythingToJSONSerializer` 会把一切数据转换为JSON数据。

如果数据是空数组，那么序列化器需要手动转换空数组（ `[]` ）为空对象（ `{}` ），这样发送给 Elasticsearch 的请求体数据才是有效的 JSON 数据。

如果数据不是数组且（或）没有转换为 JSON 数据，那么这个方法会返回 `null` 给客户端。

### Deserialize()

当 decode 响应体数据时，所有数据都会 encode 由 JSON 数据 decode 为 JSON 数据。如果数据不是有效的 JSON 数据，那么会返回 `null` 给客户端。

### 选择 EverythingToJSONSerializer

你可以通过使用 ClientBuilder 对象的 `setSerializer()` 方法来选择 `EverythingToJSONSerializer` ：

```php
<?php
$client = ClientBuilder::create()
            ->setSerializer('\Elasticsearch\Serializers\EverythingToJSONSerializer');
            ->build();
```

注意：要通过命名空间加类名的方法来配置序列化器。

## 实现自定义序列化器

如果你想使用自定义序列器，你需要实现 `SerializerInterface` 接口。请记住，对于所有的 endpoint 和连接来说，客户端只使用一个序列器对象。

```php
<?php
class MyCustomSerializer implements SerializerInterface
{

    /**
     * Serialize request body
     *
     * @param string|array $data Request body
     *
     * @return string
     */
    public function serialize($data)
    {
        // code here
    }

    /**
     * Deserialize response body
     *
     * @param string $data Response body
     * @param array  $headers Response Headers
     *
     * @return array|string
     */
    public function deserialize($data, $headers)
    {
        // code here
    }
}
```

然后为了使用你自定义的序列化器，你可以通过使用 ClientBuilder 对象的 `setSerializer()` 方法来配置序列化器（命名空间加类名格式）：

```php
<?php
$client = ClientBuilder::create()
            ->setSerializer('\MyProject\Serializers\MyCustomSerializer');
            ->build();
```

如果你的序列化器在注入到客户端前已经实例化，或者序列化器对象需要进一步初始化，你可以通过以下方式来实例化序列化器对象并注入到客户端：

```php
<?php
$mySerializer = new MyCustomSerializer($a, $b, $c);
$mySerializer->setFoo("bar");

$client = ClientBuilder::create()
            ->setSerializer($mySerializer);
            ->build();
```