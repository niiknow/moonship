# moonship
> openresty dynamic multi-tenant CMS

# features
1. Auto Letsencrypt SSL with [lua-resty-auto-ssl](https://github.com/GUI/lua-resty-auto-ssl)
2. Content retrieval from the cloud

# stragegy
1. Browser hit server with some DNS that is CNAME to `tenant_name.yourserver.com`
2. We resolve tenant_name `base` to https://{some_cdn_host}/tenant_name/web
3. Template will be `{base}/templates/page.liquid` and `home (/)` page template will be `{base}/templates/index.liquid`
4. Content will be `{base}/contents/{slug}.json` or `index.json` for home page content.
5. Content can override with it's own template.
6. Assets (javascript/images/etc) are stored in {base}/assets

**Base on the stategy above**

* Auto-ssl is approved by determining if CNAME is valid.  If Apex domain, then CNAME is lookup using `www` of the Apex domain.  Redirects are handled by rule definition under https://{s3}/tenant_name/data/web.json - if web.json exists, then domain is approved for auto-ssl.

* Redirect rules must follow the schema loosely defined here: https://github.com/niiknow/mooncrafts/blob/master/lib/mooncrafts/resty/router.moon#L8  This library was originally made to handle *FaaS*, as a result, redirect rules can contain raw code that are capable of handling HTTP request.

**And we will need the following config**
```
# passthrough env vars
# AWS S3 config
env AWS_DEFAULT_REGION;
env AWS_S3_KEY_ID;
env AWS_S3_ACCESS_KEY;
env AWS_S3_PATH;

# app stuff
env BASE_HOST; # the cname base host
env MOONSHIP_APP_PATH;
env MOONSHIP_APP_ENV; # dev, stg, prd, etc..

# set some remote url as base code repo path instead of s3
# s3 is used to store private info
# this remote URL is use to store template and content
# usually, this is /app
env MOONSHIP_BASE_PATH;
```

# build and run
osx, install lua/luarocks:
```
brew update
brew install lua
brew install openssl
make init
make test
```

# MIT
