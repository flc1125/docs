# docs

[![Build Status](https://github.com/flc1125/docs/workflows/Deploy%20Site/badge.svg)](https://github.com/flc1125/docs/actions)
[![996.icu](https://img.shields.io/badge/link-996.icu-red.svg)](https://996.icu)

- https://docs.flc.io/

## 构建

```sh
docker run -dit -v /workdir/:/docs -p 80:80 --name mkdocs flc1125/mkdocs
```

访问：http://ip:80

## 目录

### Blog

- [目录](blog/index.md)

### PHP

- [PHP 各版本特性](php/features/7.2.x.md)
- [PHP PSR 编码规范](php/psr/index.md)
- [PHPDoc 编码注释规范](php/phpdoc/index.md)
- [PHP Coding Standards Fixer](php/php-cs-fixer/index.md)
- [PHP 设计模式全集](php/php-design-patterns/index.md)

### Elasticsearch

- [Elasticsearch 简易教程](elasticsearch/simple/introduction.md)
- [Laravel-Elasticsearch 扩展文档](elasticsearch/laravel-elasticsearch/introduction.md)
- [Elasticsearch-PHP](elasticsearch/elasticsearch-php/overview.md)

### DevOps

- [CDN 科普](devops/cdn/index.md)
- [Docker](devops/docker/index.md)
- [Redis](devops/redis/index.md)

### Awesome

- [PHP](awesome/php.md)

### 更多

- [Github + Travis + Mkdocs 搭建文档库](more/github-travis-mkdocs-document/index.md)
- [Git 常用命令](more/git/index.md)
- [中文技术文档的写作规范](more/document-style-guide/index.md)
