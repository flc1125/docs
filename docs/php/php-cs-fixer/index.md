# PHP Coding Standards Fixer

## 官网

- 官网： http://cs.sensiolabs.org/
- Github: https://github.com/FriendsOfPHP/PHP-CS-Fixer

## 介绍

The PHP Coding Standards Fixer (PHP CS Fixer) tool fixes your code to follow standards; whether you want to follow PHP coding standards as defined in the PSR-1, PSR-2, etc., or other community driven ones like the Symfony one. You can also define your (teams) style through configuration.

**译文（@谷歌翻译)**

PHP编码标准修复程序（PHP CS修复程序）工具修复您的代码遵循标准;是否要遵循PSR-1，PSR-2等定义的PHP编码标准，或者像Symfony那样遵循社区驱动的标准。您还可以通过配置定义（团队）样式。

> 英语渣渣，你懂的..

## 参考命令

```bash
php-cs-fixer fix --config=.php_cs -v --using-cache=no --path-mode=intersection -- PHP文件路径
```

## 参考配置

> 文件另存为项目根目录的 `.php_cs`

```php
<?php

return PhpCsFixer\Config::create()
    ->setRiskyAllowed(true)
    ->setRules(array(
        '@Symfony' => true,
        'array_syntax' => array('syntax' => 'short'),
        'ordered_imports' => true,
        'phpdoc_order' => true,
        'no_useless_else' => true,
        'no_useless_return' => true,
        'php_unit_construct' => true,
        'php_unit_strict' => true,
        'yoda_style' => false,
        'phpdoc_summary' => false,
        'not_operator_with_successor_space' => true,
        'no_extra_consecutive_blank_lines' => true,
        'general_phpdoc_annotation_remove' => true,
        // 'ordered_class_elements' => true,
        'binary_operator_spaces' => array(
            // 'align_double_arrow' => true,
            // 'align_equals' => true,
            'default' => 'align_single_space_minimal',
        ),
    ))
    ->setFinder(
        PhpCsFixer\Finder::create()
            ->exclude('_*')
            ->exclude('vendor')
            ->exclude('storage')
            ->exclude('resources')
            ->exclude('public')
            ->in(__DIR__)
    )
;
```

## 更多

- http://flc.io/2018/05/746.html