#!/bin/sh

me=`basename "$0"`
echo "[i] MOONSHIP running: $me"

# initialize nginx folder
if [ ! -f /usr/local/openresty/nginx/conf/app/server.conf ]; then
    echo "[i] running for the 1st time"
    rsync --update -raz /usr/local/openresty/nginx/conf-bak/app/* /usr/local/openresty/nginx/conf/app

    # reload to catch new conf
    /usr/local/openresty/bin/openresty -s reload
fi
