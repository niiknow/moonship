FROM niiknow/openresty:0.2.0
LABEL maintainer="noogen <friends@niiknow.org>"
ENV LUA_PATH="/app/?.lua;/app/?/?.lua;/app/?/init.lua;/app/lib/?.lua;/app/lib/?/?.lua;/usr/local/openresty/site/lualib/?.lua;/usr/local/openresty/site/lualib/?/init.lua;/usr/local/openresty/lualib/?.lua;/usr/local/openresty/lualib/?/init.lua;/usr/local/openresty/lib/?.lua;;" \
    AWS_DEFAULT_REGION="us-east-1" \
    MOONSHIP_APP_PATH="/app" \
    MOONSHIP_APP_ENV="prd" \
    MOONSHIP_CODECACHE_SIZE=10000 \
	HOME="/root" \
    USER="root"
USER root
WORKDIR /root
RUN printf "Build of niiknow/moonship, date: %s\n"  `date -u +"%Y-%m-%dT%H:%M:%SZ"` >> /etc/BUILDS/zz-moonship && \
    apk add --no-cache --virtual runtime \
	    bash \
	    coreutils \
	    curl \
	    diffutils \
	    grep \
	    nano \
	    less \
	    python \
	    py-pip \
	    rsync \
	    sed \
	    openssl-dev && \
    apk add --no-cache --virtual .build-deps \
	    gcc \
	    libc-dev \
	    git && \
	pip install --upgrade pip && \
    pip install awscli && \
    if [ -L /usr/bin/pkill ]; then rm /usr/bin/pkill; fi && \
    luarocks install lua-resty-jwt && \
    luarocks install lua-resty-http && \
    luarocks install moonscript && \
    luarocks install luacrypto && \
    luarocks install lua-lru && \
    luarocks install basexx  && \
    luarocks install lpath && \
    luarocks install lua-log && \
    luarocks install --server=http://luarocks.org/dev ltn12 && \
    luarocks install luasec && \
    luarocks install mooncrafts && \
    addgroup -S nginx && \
    adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
    apk --purge -v del py-pip .build-deps && \
    rm -rf /var/cache/apk/*

COPY rootfs/. /
COPY lib/. /app-start/lib/
EXPOSE 80 443
VOLUME ["/app"]

