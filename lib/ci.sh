#!/bin/bash
set -e
set -o pipefail
set -o xtrace

luarocks install busted
luarocks install lua-resty-jwt 0.1.10-1
luarocks install moonscript
luarocks install httpclient 0.1.0-8
luarocks install lua-zlib 1.1-0
luarocks install luacrypto 0.3.2-2
luarocks install bcrypt 2.1-4
luarocks install penlight 1.4.1
luarocks install lua-lru 1.0-1

luarocks make

eval $(luarocks path)

# setup busted
cat $(which busted) | sed 's/\/usr\/bin\/lua5\.1/\/usr\/bin\/luajit/' > busted
chmod +x busted

make build

./busted -o utfTerminal
