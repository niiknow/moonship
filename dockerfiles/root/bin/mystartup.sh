#!/bin/bash
#

function die {
   echo >&2 "$@"
   exit 1
}

#######################################
# Echo/log function
# Arguments:
#   String: value to log
#######################################
function log {
   if [[ "$@" ]]; then echo "[`date +'%Y-%m-%d %T'`] $@";
   else echo; fi
}

if [ -n "$SERVER_CONF" ] ; then
   log "Getting new server.conf"

   mv /usr/local/openresty/nginx/sites-enabled/server.conf /usr/local/openresty/nginx/sites-enabled/server.bak
   curl -SL $SERVER_CONF --output /usr/local/openresty/nginx/sites-enabled/server.conf
fi

/usr/local/openresty/nginx/sbin/nginx -t || true