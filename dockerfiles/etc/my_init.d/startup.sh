#!/bin/bash

export TERM=xterm

# save environment variables for use later
env > /root/env.txt

mkdir -p /tmp/nginx/cache

for dir in /app /usr/local/openresty/nginx /tmp/nginx /var/cache/nginx
do
if [ ! -d $dir ]; then
	mkdir -p $dir
	chown -R  www-data:www-data $dir
else
	chown -R  www-data:www-data $dir
fi
done

if [ -f /usr/local/openresty/nginx/conf/nginx.new ]; then
   mv /usr/local/openresty/nginx/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.old
   mv /usr/local/openresty/nginx/conf/nginx.new /usr/local/openresty/nginx/conf/nginx.conf
fi

echo "*** Running /root/bin/my-startup.sh..."
bash /root/bin/mystartup.sh