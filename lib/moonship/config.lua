local util = require("mooncrafts.util")
local log = require("mooncrafts.log")
local sandbox = require("mooncrafts.sandbox")
local remoteresolver = require("mooncrafts.remoteresolver")
local requestbuilder = require("mooncrafts.requestbuilder")
local asynclogger = require("mooncrafts.asynclogger")
local aws_region = os.getenv("AWS_DEFAULT_REGION") or "us-east-1"
local aws_access_key_id = os.getenv("AWS_S3_KEY_ID")
local aws_secret_access_key = os.getenv("AWS_S3_ACCESS_KEY")
local aws_s3_code_path = os.getenv("AWS_S3_CODE_PATH")
local azure_storage = os.getenv("AZURE_STORAGE") or ""
local app_path = os.getenv("MOONSHIP_APP_PATH")
local app_env = os.getenv("MOONSHIP_APP_ENV") or "PRD"
local code_cache_size = os.getenv("MOONSHIP_CODE_CACHE_SIZE") or 10000
local remote_path = os.getenv("MOONSHIP_REMOTE_PATH")
local string_split, table_clone, string_connection_parse
string_split, table_clone, string_connection_parse = util.string_split, util.table_clone, util.string_connection_parse
local insert
insert = table.insert
local upper
upper = string.upper
local build_requires
build_requires = function(opts)
  return function(modname)
    local mod = _G[modname]
    if mod then
      return mod
    end
    local parsed = remoteresolver.resolve(modname, opts)
    if parsed._remotebase then
      local loadPath = tostring(parsed._remotebase) .. "/" .. tostring(parsed.file)
      local rsp = parsed.codeloader(loadPath)
      if (rsp.code == 200) then
        local lua_src, err = sandbox.compile_moon(rsp.body)
        if not (lua_src) then
          return nil, "error compiling `" .. tostring(modname) .. "` with message: " .. tostring(err)
        end
        local fn
        fn, err = nil, nil
        opts.plugins._remotebase = parsed._remotebase
        opts.sandbox_env = sandbox.build_env(_G, opts.plugins, sandbox.whitelist)
        fn, err = sandbox.loadstring(lua_src, modname, opts.sandbox_env)
        if not (fn) then
          return nil, "error loading `" .. tostring(modname) .. "` with message: " .. tostring(err)
        end
        local rst
        rst, err = sandbox.exec(fn)
        if not (rst) then
          return nil, "error executing `" .. tostring(modname) .. "` with message: " .. tostring(err)
        end
        _G[modname] = rst
        return rst
      end
      local _ = nil, "error loading `" .. tostring(modname) .. "` with code: " .. tostring(rsp.code)
    end
    return _G[modname], "unable to resolve `" .. tostring(modname) .. "`"
  end
end
local Config
do
  local _class_0
  local _base_0 = {
    get = function(self)
      return table_clone(self.__data, true)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, newOpts)
      if newOpts == nil then
        newOpts = { }
      end
      local defaultOpts = {
        aws_region = aws_region,
        aws_access_key_id = aws_access_key_id,
        aws_secret_access_key = aws_secret_access_key,
        aws_s3_code_path = aws_s3_code_path,
        app_path = app_path,
        code_cache_size = code_cache_size,
        remote_path = remote_path,
        azure_storage = azure_storage,
        app_env = app_env,
        plugins = { }
      }
      util.applyDefaults(newOpts, defaultOpts)
      newOpts.alog = newOpts.azure_storage
      newOpts.app_env = upper(newOpts.app_env or "PRD")
      newOpts.requestbuilder = newOpts.requestbuilder or requestbuilder()
      newOpts.plugins["require"] = newOpts.require or build_requires(newOpts)
      local req = newOpts.requestbuilder:build()
      newOpts.plugins["request"] = req
      do
        local _base_1 = req
        local _fn_0 = _base_1.log
        newOpts.plugins["log"] = function(...)
          return _fn_0(_base_1, ...)
        end
      end
      newOpts["azure"] = string_connection_parse(azure_storage or "")
      newOpts["alog"] = asynclogger({
        account_name = newOpts.azure.AccountName,
        account_key = newOpts.azure.AccountKey
      })
      self.__data = newOpts
    end,
    __base = _base_0,
    __name = "Config"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Config = _class_0
end
return Config
