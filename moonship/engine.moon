config = require "moonship.config"
codecacher = require "moonship.codecacher"
util = require "moonship.util"
sandbox = require "moonship.sandbox"

class Engine
  new: (options={}) =>
    @options = config.Config\new(options)
    @codeCache = codecacher.CodeCacher\new(@options)

  engage: (host, uri) =>
    path = util.sanitizePath(string.format("%s/%s", host, uri))
    fn = @codeCache\get(path)
    unless fn
      rsp = sandbox.exec(fn)
      return rsp

  engageOpenResty: =>
    @engage ngx.var.host, ngx.var.uri

{
  :Engine
}
