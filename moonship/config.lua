local aws_region = os.getenv("AWS_DEFAULT_REGION") or "us-east-1"
local aws_access_key = os.getenv("AWS_ACCESS_KEY_ID")
local aws_secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")
local aws_s3_code_path = os.getenv("AWS_S3_CODE_PATH")
local codecache_size = os.getenv("MOONSHIP_CODECACHE_SIZE")
local app_path = os.getenv("MOONSHIP_APP_PATH")
local Config
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, newOpts)
      if newOpts == nil then
        newOpts = { }
      end
      newOpts.aws_region = newOpts.aws_region or aws_region
      newOpts.aws_access_key = newOpts.aws_access_key or aws_access_key
      newOpts.aws_secret_key = newOpts.aws_secret_key or aws_secret_key
      newOpts.aws_s3_code_path = newOpts.aws_s3_code_path or aws_s3_code_path
      newOpts.codecache_size = newOpts.codecache_size or codecache_size
      newOpts.app_path = newOpts.app_path or app_path
      self.data = newOpts
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
