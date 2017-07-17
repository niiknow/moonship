-- certain endpoints are always blocked


validHost = os.getenv("MOONSHIP_HOST_REGEX")

if validHost
  host = ngx.var.host
  unless ngx.re.match(host, validHost)
    ngx.exit(ngx.HTTP_NOT_ALLOWED)
