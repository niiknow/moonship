
util                  = require "moonship.util"
log                   = require "moonship.log"
sandbox               = require "moonship.sandbox"

aws_region            = os.getenv("AWS_DEFAULT_REGION")
aws_access_key_id     = os.getenv("AWS_ACCESS_KEY_ID")
aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
aws_s3_code_path      = os.getenv("AWS_S3_CODE_PATH") -- 'bucket-name/basepath'
app_path              = os.getenv("MOONSHIP_APP_PATH")

code_cache_size       = os.getenv("MOONSHIP_CODE_CACHE_SIZE")
remote_path           = os.getenv("MOONSHIP_REMOTE_PATH")
app_env               = os.getenv("MOONSHIP_APP_ENV")
table_clone           = util.table_clone

remoteresolver        = require "moonship.remoteresolver"

build_requires = (opts) ->
  (modname) ->
    mod = _G[modname]
    return mod if mod

    parsed = remoteresolver.resolve(modname)

    if parsed._remotebase
      loadPath = "#{parsed._remotebase}/#{parsed.file}"

      -- log.error loadPath
      rsp = parsed.codeloader(loadPath)
      if (rsp.code == 200)
        lua_src, err = sandbox.compile_moon rsp.body

        return nil, "error compiling `#{modname}` with message: #{err}" unless lua_src

        opts.plugins["_remotebase"] = parsed._remotebase
        opts.plugins["require"] = build_requires(opts)
        fn, err = nil, nil

        oldremotebase = _G._remotebase
        _G._remotebase = parsed._remotebase
        fn, err = sandbox.loadstring lua_src, modname, opts["sandbox_env"]

        return nil, "error loading `#{modname}` with message: #{err}" unless fn

        rst, err = sandbox.exec(fn)
        --log.error rst
        --log.error err
        return nil, "error executing `#{modname}` with message: #{err}" unless rst

        _G[modname] = rst

        return rst

      nil, "error loading `#{modname}` with code: #{rsp.code }"

    _G[modname], "unable to resolve `#{modname}`"

class Config
  new: (newOpts={ aws_region: "us-east-1", code_cache_size: 10000, app_env: "prd" }) =>
    defaultOpts = {:aws_region, :aws_access_key_id, :aws_secret_access_key, :aws_s3_code_path, :app_path, :code_cache_size, :remote_path, plugins: {} }
    util.applyDefaults(newOpts, defaultOpts)
    newOpts.sandbox_env = sandbox.build_env(_G, newOpts.plugins, sandbox.whitelist)
    newOpts.plugins["require"] = newOpts.require or build_requires(newOpts)

    @__data = newOpts

  get: () => table_clone(@__data, true) -- preserving config through cloning

Config
