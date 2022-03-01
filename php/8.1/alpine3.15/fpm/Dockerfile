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

ENV PHP_VERSION 8.1.3
ENV PHP_URL=https://www.php.net/distributions/php-8.1.3.tar.xz PHP_ASC_URL=https://www.php.net/distributions/php-8.1.3.tar.xz.asc
ENV PHP_SHA256 5d65a11071b47669c17452fb336c290b67c101efb745c1dbe7525b5caf546ec6
ENV GPG_KEYS 528995BFEDFBA7191D46839EF9BA0ADA31CBD89E 39B641343D8C104B2B146DC3F9C39DC0B9698544 F1F692238FBC1666E5A5CCD4199F9DFEF6FFBAFD

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