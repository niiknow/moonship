local hmacauth = require("moonship.hmacauth")
local base64_encode = (require("moonship.crypto")).base64_encode
local util = require("moonship.util")
local url_parse, string_split, query_string_encode
url_parse, string_split, query_string_encode = util.url_parse, util.string_split, util.query_string_encode
local concat, sort
do
  local _obj_0 = table
  concat, sort = _obj_0.concat, _obj_0.sort
end
local date_utc, sharedkeylite, canonicalizedResource, canonicalizedHeaders, getHeader, stringForTable, stringForBlobOrQueue, sign
date_utc = function(date)
  if date == nil then
    date = os.time()
  end
  return os.date("!%a, %d, %b, %Y %H:%M:%S GMT", date)
end
sharedkeylite = function(opts)
  if opts == nil then
    opts = {
      account_name = account_name,
      account_key = account_key,
      table_name = table_name
    }
  end
  opts.date = opts.date or date_utc()
  opts.sig = hmacauth.sign(base64_decode(opts.account_key), tostring(opts.date) .. "\n/" .. tostring(opts.account_name) .. "/" .. tostring(opts.table_name))
  return opts
end
canonicalizedResource = function(opts)
  local parsedUrl = opts.parsedUrl
  local query = string_split(opts.query, "&")
  local qs = query_string_encode(query, "\n", "", function(v)
    return v
  end)
  local params = {
    "/" .. tostring(opts.account_name) .. tostring(parsedUrl.path),
    qs
  }
  return concat(params, "\n")
end
canonicalizedHeaders = function(headers)
  local rst = { }
  local keys = { }
  for k in pairs(headers) do
    keys[#keys + 1] = tostring(k)
  end
  sort(keys)
  for _, k in ipairs(keys) do
    local v = headers[k]
    if (k:find("x-ms-") == 1) then
      rst[#rst + 1] = tostring(k) .. ":" .. tostring(v)
    end
  end
  return concat(rst, "\n")
end
getHeader = function(headers, name, additionalHeaders)
  if additionalHeaders == nil then
    additionalHeaders = { }
  end
  if headers[name] then
    return headers[name]
  end
  if additionalHeaders[name] then
    return additionalHeaders[name]
  end
  return ''
end
stringForTable = function(opts, additionalHeaders)
  additionalHeaders["DataServiceVersion"] = "3.0;NetFx"
  additionalHeaders["MaxDataServiceVersion"] = "3.0;NetFx"
  local params = {
    opts.method,
    getHeader(opts.headers, "content-md5"),
    getHeader(opts.headers, "content-type"),
    getHeader(opts.headers, "x-ms-date", additionalHeaders),
    getHeader(opts.headers, "content-md5"),
    getHeader(opts.headers, "content-type"),
    getHeader(opts.headers, "x-ms-date", additionalHeaders),
    canonicalizedResource(parsedUrl)
  }
  return concat(params, "\n")
end
stringForBlobOrQueue = function(req, additionalHeaders)
  local headers = { }
  table_extend(headers, opts.headers)
  table_extend(headers, additionalHeaders)
  local params = {
    req.method,
    getHeader(headers, "content-encoding"),
    getHeader(headers, "content-language"),
    getHeader(headers, "content-length"),
    getHeader(headers, "content-md5"),
    getHeader(headers, "content-type"),
    getHeader(headers, "date"),
    getHeader(headers, "if-modified-since"),
    getHeader(headers, "if-match"),
    getHeader(headers, "if-none-match"),
    getHeader(headers, "if-unmodified-since"),
    getHeader(headers, "range"),
    canonicalizedHeaders(headers),
    canonicalizedResource(opts)
  }
  return concat(params, "\n")
end
sign = function(opts, stringGenerator)
  if stringGenerator == nil then
    stringGenerator = stringForTable
  end
  opts.time = opts.time or os.time()
  opts.parsedUrl = url_parse(opts.url)
  local additionalHeaders = { }
  additionalHeaders["x-ms-version"] = "2016-05-31"
  additionalHeaders["x-ms-date"] = date_utc(opts.time)
  local stringToSign = stringGenerator(opts, additionalHeaders)
  local sig = hmacauth.sign(base64_decode(opts.account_key), stringToSign)
  additionalHeaders["Authorization"] = "SharedKey " .. tostring(opts.account_name) .. ":" .. tostring(sig)
  return additionalHeaders
end
return {
  date_utc = date_utc,
  sharedkeylite = sharedkeylite
}
