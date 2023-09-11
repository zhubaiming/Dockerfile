# 使用多阶段构建生产镜

ARG IMAGE=alpine
ARG IMAGE_VERSION=3.18

# 第一阶段，命名为 build
FROM ${IMAGE}:${IMAGE_VERSION} as build

ARG NGINX_VERSION=1.24.0

RUN set -x \
    && apk update \
    && apk add --no-cache \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre2-dev \
        zlib-dev \
        linux-headers \
        libxslt-dev \
        gd-dev \
        geoip-dev \
        libedit-dev \
        bash \
        alpine-sdk \
        findutils \
        tzdata \
    && tempDir="$(mktemp -d)" \
    && chown nobody:nobody $tempDir \
    && cd ${tempDir} \
    && wget -O ./nginx.tar.gz https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && wget -O ./nginx.tar.gz.asc https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz.asc  \
    && tar zxvf nginx.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && mkdir -p /etc/nginx \
                /var/log/nginx \
                /var/run/nginx \
    && ./configure \
        --user=nginx \
        --group=nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --with-threads \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_stub_status_module \
        --without-http_ssi_module \
        --without-http_autoindex_module \
        --without-http_memcached_module \
    && make -j4 \
    && make install

# 第二阶段
FROM ${IMAGE}:${IMAGE_VERSION}

ARG TZ=Asia/Shanghai

COPY --from=build /usr/sbin/nginx /usr/sbin/
COPY --from=build /etc/nginx/ /etc/nginx/
COPY --from=build /var/log/nginx/ /var/log/nginx/
COPY --from=build /var/run/ /var/run/
COPY --from=build /usr/local/nginx/html/ /usr/share/nginx/html/

COPY --from=build /usr/share/zoneinfo/${TZ} /etc/localtime

COPY ./nginx.conf.default /etc/nginx/nginx.conf
COPY ./conf.d/default.conf /etc/nginx/conf.d/default.conf

RUN set -x \
    && addgroup -g 101 -S nginx \
    && adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && apk update \
    && apk add --no-cache pcre2-dev \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && mkdir -p -m 700 /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp /var/cache/nginx/fastcgi_temp /var/cache/nginx/uwsgi_temp /var/cache/nginx/scgi_temp \
    && chown -R nginx /var/cache/nginx/* \
    && echo ${TZ} /etc/timezone

WORKDIR /etc/nginx

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]