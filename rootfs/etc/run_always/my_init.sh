#!/bin/sh

me=`basename "$0"`
echo "[i] MOONSHIP running: $me"

mkdir -p /app

# rsync app
if [ -z "`ls /app --hide='lost+found'`" ]
then
    rsync -a /app-start/* /app
fi

mkdir -p /app/tmp/cache/code/public
mkdir -p /app/tmp/cache/code/private
mkdir -p /app/tmp/nginx/temp

chown -R nginx:nginx /app

# make sure runit services are running across restart
find /etc/service/ -name "down" -exec rm -rf {} \;

ln -sf /app/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ln -sf /dev/stdout /app/log/nginx/access.log
ln -sf /dev/stderr /app/log/nginx/error.log
