# Welcome to MkDocs

For full documentation visit [mkdocs.org](http://mkdocs.org).

## Commands

* `mkdocs new [dir-name]` - Create a new project.
* `mkdocs serve` - Start the live-reloading docs server.
* `mkdocs build` - Build the documentation site.
* `mkdocs help` - Print this help message.

## Project layout

    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        ...       # Other markdown pages, images and other files.

## 测试中文

> 测试中文

- 测试中文
- 测试中文

**测试中文**

- [ ] 测试中文
- [x] 测试中文

```php
<?php
/**
 * 自动载入
 *
 * @author Flc <2016-10-25 17:35:52>
 * @link http://flc.ren 
 */
spl_autoload_register(function ($classname) {
    $baseDir = __DIR__  . DIRECTORY_SEPARATOR . 'src' . DIRECTORY_SEPARATOR . 'Alidayu' . DIRECTORY_SEPARATOR;

    if (strpos($classname, "Flc\\Alidayu\\") === 0) {
        $path = str_replace('\\', DIRECTORY_SEPARATOR, substr($classname, strlen('Flc\\Alidayu\\')));
        $file = $baseDir . $path . '.php';

        if (is_file($file))
            require_once $file;
    }
});
```