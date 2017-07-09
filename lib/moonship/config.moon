
util    = require "moonship.util"
log     = require "moonship.logger"
sandbox = require "moonship.sandbox"

aws_region            = os.getenv("AWS_DEFAULT_REGION")
aws_access_key_id     = os.getenv("AWS_ACCESS_KEY_ID")
aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
aws_s3_code_path      = os.getenv("AWS_S3_CODE_PATH") -- 'bucket-name/basepath'
app_path              = os.getenv("MOONSHIP_APP_PATH")

code_cache_size       = os.getenv("MOONSHIP_CODE_CACHE_SIZE")
remote_path           = os.getenv("MOONSHIP_REMOTE_PATH")
app_env               = os.getenv("MOONSHIP_APP_ENV")

table_clone           = util.table_clone

_data = {}

build_requires = (opts) ->
  (modname) ->
    unless _G[modname]
      base, file, query = util.resolveGithubRaw(modname)
      if base
        loadPath = "#{base}#{file}#{query}"
        rsp = loadCode(loadPath)
        if (rsp.code == 200)
          lua_src, err = sandbox.compile_moon rsp.body

          return nil, "error compiling '#{modname}' with message: #{err}" unless lua_src

          fn, err = sandbox.loadstring_safe lua_src, loadPath, opts.sandbox_env
          _G["__remotebase"] = base
          return nil, "error loading '#{modname}' with message: #{err}" unless fn

          rst, err = sandbox.exec(fn)
          return nil, "error executing '#{modname}' with message: #{err}" unless rst

          _G[modname] = rst

    _G[modname]

class Config
  new: (newOpts={ aws_region: "us-east-1", code_cache_size: 10000, app_env: "prd" }) =>
    defaultOpts = {:aws_region, :aws_access_key_id, :aws_secret_access_key, :aws_s3_code_path, :app_path, :code_cache_size, :remote_path }
    util.applyDefaults(newOpts, defaultOpts)

    newOpts.sandbox_env = sandbox.build_env(_G, newOpts.plugins or {}, sandbox.whitelist)
    newOpts.require = build_requires(newOpts)
    _data = newOpts

  get: () => table_clone(_data)

Config
