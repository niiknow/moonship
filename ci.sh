#!/bin/bash
set -e
set -o pipefail
set -o xtrace

luarocks-5.1 install busted
luarocks-5.1 install lpeg 0.10.2
luarocks-5.1 install moonscript
luarocks-5.1 install luaposix
luarocks-5.1 install date

luarocks-5.1 install lua-resty-http 0.08-0
luarocks-5.1 install lua-resty-string 0.09-0
luarocks-5.1 install lua-lru 1.0-1
luarocks-5.1 install bcrypt 2.1-4
luarocks-5.1 install luacrypto 0.3.2-2
luarocks-5.1 install lua-resty-hmac v1.0-1
luarocks-5.1 install lua-api-gateway-aws 1.7.1-0
luarocks-5.1 install lua-resty-jwt 0.1.10-1
luarocks-5.1 install md5 1.2-1
luarocks-5.1 install basexx 0.3.0-1
luarocks-5.1 install penlight 1.4.1

luarocks-5.1 make

eval $(luarocks-5.1 path)

# setup busted
cat $(which busted) | sed 's/\/usr\/bin\/lua5\.1/\/usr\/bin\/luajit/' > busted
chmod +x busted

make build

./busted -o utfTerminal
