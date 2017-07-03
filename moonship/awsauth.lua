local crypto = require("moonship.crypto")
local util = require("moonship.util")
local AwsAuth
do
  local _class_0
  local _base_0 = {
    get_canonical_header = function(self)
      local h = {
        "content-type:" .. self.options.content_type,
        "host:" .. self.options.aws_host,
        "x-amz-date:" .. self.options.iso_tz
      }
      return table.concat(h, "\n")
    end,
    get_signed_request_body = function(self)
      local params = self.options.request_body
      if type(self.options.request_body) == "table" then
        table.sort(params)
        params = util.query_string_encode(params)
      end
      local digest = self:get_sha256_digest(params or "")
      return string.lower(digest)
    end,
    get_canonical_request = function(self)
      local param = {
        self.options.request_method,
        self.options.request_path,
        "",
        self:get_canonical_header(),
        "",
        "content-type;host;x-amz-date",
        self:get_signed_request_body()
      }
      local canonical_request = table.concat(param, "\n")
      return self:get_sha256_digest(canonical_request)
    end,
    get_sha256_digest = function(self, s)
      return crypto.sha256(s).hex()
    end,
    hmac = function(self, secret, message)
      return crypto.hmac(secret, message, crypto.sha256)
    end,
    get_signing_key = function(self)
      local k_date = self:hmac("AWS4" .. self.options.aws_secret, self.options.iso_date).digest()
      local k_region = self:hmac(k_date, self.options.aws_region).digest()
      local k_service = self:hmac(k_region, self.options.aws_service).digest()
      return self:hmac(k_service, "aws4_request").digest()
    end,
    get_string_to_sign = function(self)
      local param = {
        self.options.iso_date,
        self.options.aws_region,
        self.options.aws_service,
        "aws4_request"
      }
      local cred = table.concat(param, "/")
      local req = self:get_canonical_request()
      return table.concat({
        "AWS4-HMAC-SHA256",
        self.options.iso_tz,
        cred,
        req
      }, "\n")
    end,
    get_signature = function(self)
      local signing_key = self:get_signing_key()
      local string_to_sign = self:get_string_to_sign()
      return self:hmac(signing_key, string_to_sign).hex()
    end,
    get_authorization_header = function(self)
      local param = {
        self.options.aws_key,
        self.options.iso_date,
        self.options.aws_region,
        self.options.aws_service,
        "aws4_request"
      }
      local header = {
        "AWS4-HMAC-SHA256 Credential=" .. table.concat(param, "/"),
        "SignedHeaders=content-type;host;x-amz-date",
        "Signature=" .. self:get_signature()
      }
      return table.concat(header, ", ")
    end,
    get_auth_headers = function(self)
      return {
        ["Authorization"] = self:get_authorization_header(),
        ["x-amz-date"] = self:get_date_header(),
        ["x-amz-content-sha256"] = self:get_content_sha256(),
        ["Content-Type"] = self.options.content_type
      }
    end,
    get_date_header = function(self)
      return self.options.iso_tz
    end,
    get_content_sha256 = function(self)
      return get_sha256_digest("")
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, options)
      if options == nil then
        options = { }
      end
      local microtime = os.time()
      options.aws_host = options.aws_host or "s3.amazonaws.com"
      options.aws_region = options.aws_region or "us-east-1"
      options.aws_service = options.aws_service or "s3"
      options.content_type = options.content_type or "application/x-www-form-urlencoded"
      options.request_method = options.request_method or "GET"
      options.request_path = options.request_path or "/"
      options.request_body = options.request_body or ""
      options.iso_date = options.iso_date or os.date("!%Y%m%d", microtime)
      options.iso_tz = options.iso_tz or os.date("!%Y%m%dT%H%M%SZ", microtime)
      self.options = options
    end,
    __base = _base_0,
    __name = "AwsAuth"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  AwsAuth = _class_0
end
return {
  AwsAuth = AwsAuth
}
