FROM alpine:3.15.0

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

# 创建配置文件目录；创建项目存放目录，并改变权限及所属
RUN set -eux; \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \
    echo "修改国内镜像源成功"; \
    apk update && apk upgrade; \
    apk add --no-cache curl; \
    \
    adduser -u 82 -D -S -G www-data www-data; \
    echo "添加用户成功"; \
    \
    mkdir -p "$PHP_INI_DIR/conf.d"; \
    echo "创建配置文件目录成功"; \
    \
    [ ! -d /var/www/html ]; \
    mkdir -p /var/www/html; \
    chown www-data:www-data /var/www/html; \
    chmod 777 /var/www/html; \
    echo "创建项目运行目录成功"; \
    \
    touch /tmp/demo.log; \
    echo "test" >> /tmp/demo.log;

ENV PHP_VERSION 7.4.27
ENV PHP_URL="https://www.php.net/distributions/php-7.4.27.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-7.4.27.tar.xz.asc"
ENV PHP_SHA256="3f8b937310f155822752229c2c2feb8cc2621e25a728e7b94d0d74c128c43d0c"
ENV GPG_KEYS 42670A7FE4D0441C8E4632349E4FDC074A4EF02D 5A52880781F755608BF815FC910DEB46F53EA312

# 下载php压缩包；php加密验证包；对下载对php压缩包进行验证
RUN set -eux; \
    apk add --no-cache --virtual .fetch-deps gnupg; \
    echo "创建虚拟包 .fetch-deps 成功"; \
    \
    cd /tmp; \
    curl -fsSL -o php.tar.xz "$PHP_URL"; \
    echo "下载 php 压缩包成功"; \
    \
    if [ -n "$PHP_SHA256" ]; then \
      echo "PHP_SHA256 字符串不为空，且长度不为0"; \
      echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c; \
    fi; \
    \
    if [ -n "$PHP_ASC_URL" ]; then \
      echo "PHP_ASC_URL 字符串不为空，且长度不为0"; \
      curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
      echo "下载 php 加密验证压缩包成功"; \
      \
      export GNUPGHOME="$(mktemp -d)"; \
      echo "创建临时文件夹并设置环境变量 GNUPGHOME"; \
      \
      for key in $GPG_KEYS; do \
        gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
      done; \
      gpg --batch --verify php.tar.xz.asc php.tar.xz; \
      echo "验证 php 压缩包签名成功"; \
      \
      gpgconf --kill all; \
      rm -rf "$GNUPGHOME"; \
    fi; \
    apk del --no-network .fetch-deps; \
    echo "删除虚拟包 .fetch-deps 成功";

# 添加安装临时环境，并安装编译所需库；编译php源码并安装
#RUN set -eux; \
#    apk add --no-cache --virtual .build-deps \


# 安装php扩展包；安装composer


WORKDIR /var/www/html

EXPOSE 9000

CMD ["tail", "-f", "/tmp/demo.log"]
