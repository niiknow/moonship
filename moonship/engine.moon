config = require "moonship.config"
codecacher = require "moonship.codecacher"
util = require "moonship.util"

-- response with
-- :body, :code, :headers, :status, :error
class Engine
  new: (options={}) =>
    @options = config.Config\new(options)
    if (options.useS3)
      options.aws = {
        aws_access_key_id: options.aws_access_key_id,
        aws_secret_access_key: options.aws_secret_access_key,
        aws_s3_code_path: options.aws_s3_code_path
      }
    @codeCache = codecacher.CodeCacher\new(@options)

  handleResponse: (rst) =>
    if type(rst) ~= 'table'
      return {body: rst, code: 500, status: "500 unexpected response", headers: {'Content-Type': "text/plain"}}

    rst.code = rst.code or 200
    rst.headers["Content-Type"] = rst.headers["Content-Type"] or "text/plain"
    rst

  engage: (host=(ngx and ngx.var.host), uri=(ngx and ngx.var.uri)) =>
    path = util.sanitizePath(string.format("%s/%s", host, uri))
    rst = @codeCache.get(path)
    unless rst and rst.value
      return @handleResponse(rst)

    { error: err, code: 500, status: "500 Engine.engage error" }

{
  :Engine
}
