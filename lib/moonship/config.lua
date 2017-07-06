local util = require("moonship.util")
local log = require("moonship.log")
local aws_region = os.getenv("AWS_DEFAULT_REGION")
local aws_access_key_id = os.getenv("AWS_ACCESS_KEY_ID")
local aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
local aws_s3_code_path = os.getenv("AWS_S3_CODE_PATH")
local app_path = os.getenv("MOONSHIP_APP_PATH")
local code_cache_size = os.getenv("MOONSHIP_CODE_CACHE_SIZE")
local remote_path = os.getenv("MOONSHIP_REMOTE_PATH")
local table_clone = util.table_clone
local _data = { }
local Config
do
  local _class_0
  local _base_0 = {
    get = function(self)
      return table_clone(_data)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, newOpts)
      if newOpts == nil then
        newOpts = {
          aws_region = 'us-east-1',
          code_cache_size = 10000
        }
      end
      local defaultOpts = {
        aws_region = aws_region,
        aws_access_key_id = aws_access_key_id,
        aws_secret_access_key = aws_secret_access_key,
        aws_s3_code_path = aws_s3_code_path,
        app_path = app_path,
        code_cache_size = code_cache_size,
        remote_path = remote_path
      }
      util.applyDefaults(newOpts, defaultOpts)
      _data = newOpts
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
return {
  Config = Config
}
