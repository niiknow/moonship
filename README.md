# moonship
> we put a man on the moon

This is a library providing Function as a Service (*FaaS*) for moonscript and lua with openresty.

environment variables
```
# passthrough env vars
# AWS S3 code repo config
env AWS_DEFAULT_REGION;
env AWS_S3_KEY_ID;
env AWS_S3_ACCESS_KEY;
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
make init
make test
```

run tests
```
make
```

run demo local web server, then open: http://localhost:4000/hello
```
moon lib/server.moon
```

# MIT
