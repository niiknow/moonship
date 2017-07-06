# moonship
openresty dynamic moonscript

# build and run
http://leafo.net/posts/getting_started_with_moonscript.html

osx, install lua/luarocks:
```
brew update
brew install lua
brew install openssl
brew install zlib
luarocks install lua-zlib ZLIB_DIR=/usr/local/opt/zlib

luarocks install busted
luarocks install moonscript
luarocks install lua-resty-jwt 0.1.10-1
luarocks install httpclient 0.1.0-8
luarocks install luacrypto 0.3.2-2
luarocks install bcrypt 2.1-4
luarocks install penlight 1.4.1
luarocks install lua-lru 1.0-1

```

run tests
```
make
```

run demo local web server, then open: http://localhost:4000/hello
```
moon lib/server.moon
```

