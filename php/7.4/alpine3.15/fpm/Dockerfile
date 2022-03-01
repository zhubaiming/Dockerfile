#
# NOTE: 当前文件由 "apply_templates.sh" 生成
#
# 请勿直接修改
#

FROM alpine:3.15

ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev dpkg \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkgconf \
		re2c

ENV PHP_INI_DIR /usr/local/etc/php


RUN set -eux; \
    
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    apk update && apk upgrade; \
    apk add --no-cache curl; \
    \
    
    adduser -u 82 -D -S -G www-data www-data; \
    \
    
    mkdir -p "$PHP_INI_DIR/conf.d"; \
    \
    [ ! -d /var/www/html ]; \
    
    mkdir -p /var/www/html; \
    chown www-data:www-data /var/www/html; \
    chmod 777 /var/www/html; \

ENV PHP_VERSION 7.4.28
ENV PHP_URL=https://www.php.net/distributions/php-7.4.28.tar.xz PHP_ASC_URL=https://www.php.net/distributions/php-7.4.28.tar.xz.asc
ENV PHP_SHA256 9cc3b6f6217b60582f78566b3814532c4b71d517876c25013ae51811e65d8fce
ENV GPG_KEYS 42670A7FE4D0441C8E4632349E4FDC074A4EF02D 5A52880781F755608BF815FC910DEB46F53EA312

# 下载php压缩包；php加密验证包；对下载对php压缩包进行验证
# 使用记忆功能，添加编译环境，并安装编译所需库；记忆功能以便去掉打包过程中才会使用的包，从而缩减最终容器尺寸



RUN set -eux; \
    
    apk add --no-cache --virtual .fetch-deps curl gnupg; \
    \
    cd /tmp; \
    curl -fsSL -o php.tar.xz "$PHP_URL"; \
    \


# 添加安装临时环境，并安装编译所需库；编译php源码并安装
RUN set -eux; \
    apk add --no-cache --virtual .fetch-deps gnupg; \

WORKDIR /var/www/html

EXPOSE 9000

# 以下内容仅在测试文档生成容器期间使用
RUN touch /tmp/demo.log; \
    && echo "test" >> /tmp/demo.log;
CMD ["tail", "-f", "/tmp/demo.log"]
# 以上内容在文档测试无误后删除，并启用下面 CMD 命令
#CMD ["php-fpm"]


# 本文件由作者：baiming.zhu 编写并维护，版权所有