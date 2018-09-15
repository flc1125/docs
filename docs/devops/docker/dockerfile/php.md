# PHP

## 1. 概述

- PHP-7.2
- 常用扩展
- Redis
- swoole
- composer

## 2. Dockerfile

> 示例：php-7.2 版本

### 2.1. 配置

```dockerfile
FROM php:7.2.9

# php extension
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) bcmath \
        iconv \
        mysqli \
        gettext \
        pcntl \
        pdo_mysql \
        sysvsem \
        sockets \
        zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN pecl install redis \
    && pecl install swoole \
    && docker-php-ext-enable redis swoole

# php composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

CMD ['php', '-v']
```

### 2.2. 构建镜像

```bash
docker build -t php-7.2 .
```

## 3. Docker Hub 镜像

- 镜像地址：https://hub.docker.com/r/flc1125/php-7.2/

### 3.1. 拉取镜像

```bash
docker pull flc1125/php-7.2
```

### 3.2. 运行一个容器

```
docker run -dit --name php-7.2 flc1125/php-7.2 bash
```
