
util                  = require "moonship.util"
log                   = require "moonship.log"
sandbox               = require "moonship.sandbox"
remoteresolver        = require "moonship.remoteresolver"
requestbuilder        = require "moonship.requestbuilder"

aws_region            = os.getenv("AWS_DEFAULT_REGION") or "us-east-1"
aws_access_key_id     = os.getenv("AWS_ACCESS_KEY_ID")
aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
azure_storage         = os.getenv("AZURE_STORAGE") or ""
app_path              = os.getenv("MOONSHIP_APP_PATH")

code_cache_size       = os.getenv("MOONSHIP_CODE_CACHE_SIZE") or 10000
aws_s3_code_path      = os.getenv("AWS_S3_CODE_PATH") -- 'bucket-name/basepath'
remote_path           = os.getenv("MOONSHIP_REMOTE_PATH")
app_env               = os.getenv("MOONSHIP_APP_ENV") or "prd"

import string_split, table_clone, string_connection_parse from util
import insert from table

env_id = (env="prd") ->
  switch type env
    when "dev"
      return 79
    when "tst"
      return 77
    when "uat"
      return 75
    when "stg"
      return 73
    when "prd"
      return 71

  -- default to dev
  return 79

build_requires = (opts) ->
  (modname) ->
    mod = _G[modname]
    return mod if mod

    parsed = remoteresolver.resolve(modname, opts)

    if parsed._remotebase
      loadPath = "#{parsed._remotebase}/#{parsed.file}"

      -- log.error loadPath
      rsp = parsed.codeloader(loadPath)
      if (rsp.code == 200)
        lua_src, err = sandbox.compile_moon rsp.body

        return nil, "error compiling `#{modname}` with message: #{err}" unless lua_src

        fn, err = nil, nil

        opts.plugins._remotebase = parsed._remotebase
        opts.sandbox_env = sandbox.build_env(_G, opts.plugins, sandbox.whitelist)
        fn, err = sandbox.loadstring lua_src, modname, opts.sandbox_env

        return nil, "error loading `#{modname}` with message: #{err}" unless fn

        rst, err = sandbox.exec(fn)
        return nil, "error executing `#{modname}` with message: #{err}" unless rst

        _G[modname] = rst

        return rst

      nil, "error loading `#{modname}` with code: #{rsp.code }"

    _G[modname], "unable to resolve `#{modname}`"

class Config
  new: (newOpts={}) =>
    defaultOpts = {
      :aws_region, :aws_access_key_id, :aws_secret_access_key, :aws_s3_code_path,
      :app_path, :code_cache_size, :remote_path, :azure_storage, :app_env, plugins: {}
    }

    util.applyDefaults(newOpts, defaultOpts)
    newOpts.app_env = newOpts.app_env or "prd"
    newOpts.requestbuilder = newOpts.requestbuilder or requestbuilder()
    newOpts.plugins["require"] = newOpts.require or build_requires(newOpts)
    req = newOpts.requestbuilder\build()
    newOpts.plugins["request"] = req
    newOpts.plugins["log"] = req\log
    newOpts.app_env_id = env_id(newOpts.app_env)

    -- parsing azure storage connection string
    newOpts["azure"] = string_connection_parse(azure_storage or "")

    @__data = newOpts

  get: () => table_clone(@__data, true) -- preserving config through cloning

Config
