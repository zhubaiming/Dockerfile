FROM alpine:3.15.0

#ENV

#ENV PHP_INI_DIR /usr/local/etc/php

# 创建配置文件目录；创建项目存放目录，并改变权限及所属
#RUN set -eux; \
#    mkdir -p "$PHP_INI_DIR/conf.d"; \
#    [ ! -d /var/www/html ]; \
#    mkdir -p /var/www/html; \
#    chown www-data:www-data /var/www/html; \
#    chmod 777 /var/www/html; \
#    touch /tmp/demo.log; \
#    echo "test" >> /tmp/demo.log;

#ENV PHP_VERSION 7.4.27
#ENV PHP_URL = "https://www.php.net/distributions/php-7.4.27.tar.xz" PHP_ASC_URL = "https://www.php.net/distributions/php-7.4.27.tar.xz.asc"
#ENV PHP_SHA256 = "3f8b937310f155822752229c2c2feb8cc2621e25a728e7b94d0d74c128c43d0c"

RUN touch /tmp/demo.log; \
    echo "test" >> /tmp/demo.log;

CMD ["tail", "-f", "/tmp/demo.log"]
