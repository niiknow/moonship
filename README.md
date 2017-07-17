# moonship
openresty dynamic moonscript

environment variables
```
# passthrough env vars
# AWS S3 code repo config
env AWS_DEFAULT_REGION;
env AWS_ACCESS_KEY_ID;
env AWS_SECRET_ACCESS_KEY;
env AWS_S3_CODE_PATH;

# access by lua
env MOONSHIP_HOST_REGEX;

# azure
env AZURE_STORAGE;

# app stuff
env MOONSHIP_APP_PATH;
env MOONSHIP_APP_ENV;

# size of code to cache per worker, depend on server ram - default 10000
env MOONSHIP_CODECACHE_SIZE;

# set some remote url as base code repo path instead of s3
env MOONSHIP_REMOTE_PATH;
```

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
luarocks install lua-lru 1.0-1
luarocks install basexx 0.1.0-1
luarocks install lpath 0.1.0-1 
luarocks install lua-log 0.1.6-1
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

