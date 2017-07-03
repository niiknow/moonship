#!/bin/bash
set -e
set -o pipefail
set -o xtrace

luarocks-5.1 install busted
luarocks-5.1 install lpeg 0.10.2
luarocks-5.1 install moonscript
luarocks-5.1 install luaposix
luarocks-5.1 install date
luarocks-5.1 make

eval $(luarocks-5.1 path)

# setup busted
cat $(which busted) | sed 's/\/usr\/bin\/lua5\.1/\/usr\/bin\/luajit/' > busted
chmod +x busted

make build

./busted -o utfTerminal