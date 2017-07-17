local validHost = os.getenv("MOONSHIP_HOST_REGEX")
if validHost then
  local host = ngx.var.host
  if not (ngx.re.match(host, validHost)) then
    return ngx.exit(ngx.HTTP_NOT_ALLOWED)
  end
end
