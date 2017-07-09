# moonship
openresty dynamic moonscript

# build and run
http://leafo.net/posts/getting_started_with_moonscript.html

osx, install lua/luarocks:
```
brew update
brew install lua
brew install openssl
luarocks install luasec CRYPTO_DIR=/usr/local/opt/openssl OPENSSL_DIR=/usr/local/opt/openssl

luarocks install busted
luarocks install lua-resty-jwt 0.1.10-1
luarocks install lua-resty-http 0.08-0
luarocks install moonscript
luarocks install luacrypto 0.3.2-2
luarocks install bcrypt 2.1-4
luarocks install lpath 0.1.0-1 
luarocks install lua-lru 1.0-1
luarocks install basexx 0.1.0-1
luarocks install --server=http://luarocks.org/dev ltn12

# this is for local only, openresty uses lua-resty-http
luarocks install http

```

run tests
```
make
```

run demo local web server, then open: http://localhost:4000/hello
```
moon lib/server.moon
```

