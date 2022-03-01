#
# NOTE: 当前文件由 "apply_templates.sh" 生成
#
# 请勿直接修改
#

FROM debian:buster-slim

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

ENV WORK_DIR /var/www/html
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
    [ ! -d "$WORK_DIR" ]; \
    mkdir -p "$WORK_DIR""; \
    chown www-data:www-data "$WORK_DIR"; \
    chmod 777 "$WORK_DIR"

ENV PHP_BUILD_DIR /usr/src/php
ENV PHP_VERSION 7.4.28
ENV PHP_URL="https://www.php.net/distributions/php-7.4.28.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-7.4.28.tar.xz.asc"
ENV PHP_SHA256="9cc3b6f6217b60582f78566b3814532c4b71d517876c25013ae51811e65d8fce"
ENV GPG_KEYS 42670A7FE4D0441C8E4632349E4FDC074A4EF02D 5A52880781F755608BF815FC910DEB46F53EA312

RUN set -eux; \
    apk add --no-cache --virtual .fetch-deps curl gnupg tar; \
    \
    cd /tmp; \
    curl -fsSL -o php.tar.xz "$PHP_URL"; \
    \
    if [ -n "$PHP_SHA256" ]; then \
        echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c;
    fi; \
    \
    if [ -n "$PHP_ASC_URL" ]; then \
        curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL";\
        \
        export GNUPGHOME="$(mktemp -d)"; \
        \
        for key in $GPG_KEYS; do \
            gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
        done; \
        gpg --batch --verify php.tar.xz.asc php.tar.xz; \
        \
        gpgconf --kill all; \
        rm -rf "$GNUPGHOME"; \
    fi; \
    \
    mkdir -p "$PHP_BUILD_DIR"; \
    tar -Jxf /tmp/php.tar.xz -C "$PHP_BUILD_DIR" --strip-components=1; \
    \
    apk del --no-network .fetch-deps

ENV PHP_DIR /usr/php
ENV PHP_CONF_DIR /etc/php

RUN set -eux; \
    apk add --no-cache --virtual .build-deps; \

    cd "$PHP_BUILD_DIR"; \
    \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    \
    ./configure \
            --build="$gnuArch" \
            \
            --prefix="$PHP_DIR" \
            \
            --disable-option-checking \
            \
            --enable-fpm \
            --with-fpm-user=www-data \
            --with-fpm-group=www-data \
            --disable-cgi \
            \
            --with-config-file-path="$PHP_INI_DIR" \
            --disable-short-tags \
            \
            --enable-bcmath \
            --with-openssl \
            --with-password-argon2 \
            --with-mhash \
            --with-sodium=shared \
            --enable-mbstring \
            --enable-exif \
            --with-curl \
    ; \
    make -j "$(nproc)";\
    make install; \
    make clean; \
    \
    cp php-ini.* "$PHP_CONF_DIR" \
    \
    apk del --no-network .build-deps

WORKDIR /var/www/html

EXPOSE 9000

# 以下内容仅在测试文档生成容器期间使用
RUN touch /tmp/demo.log; \
    && echo "test" >> /tmp/demo.log;
CMD ["tail", "-f", "/tmp/demo.log"]
# 以上内容在文档测试无误后删除，并启用下面 CMD 命令
#CMD ["php-fpm"]


# 本文件由作者：baiming.zhu 编写并维护，版权所有