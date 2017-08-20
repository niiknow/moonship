#!/bin/sh

me=`basename "$0"`
echo "[i] MOONSHIP running: $me"

# rsync app
if [ -z "`ls /app --hide='lost+found'`" ]
then
    rsync -a /app-start/* /app
    rsync -a /sysprepz/home/* /home
fi

mkdir -p /app/tmp/nginx/cache/code/public
mkdir -p /app/tmp/nginx/cache/code/private
mkdir -p /app/tmp/nginx/temp

chown -R nginx:nginx /app

# make sure runit services are running across restart
find /etc/service/ -name "down" -exec rm -rf {} \;
