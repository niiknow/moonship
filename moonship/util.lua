local url = require("socket.url")
local cjson_safe = require("cjson.safe")
local concat, insert
do
  local _obj_0 = table
  concat, insert = _obj_0.concat, _obj_0.insert
end
local url_unescape, url_escape, url_parse, url_build, trim, slugify, split, sanitizePath, json_encodable, to_json, from_json, query_string_encode
url_unescape = function(str)
  return url.unescape(str)
end
url_escape = function(str)
  return url.escape(str)
end
url_parse = function(str)
  return url.parse(str)
end
url_build = function(parts)
  local out = parts.path or ""
  if not (parts.query) then
    out = out .. ("?" .. parts.query)
  end
  if not (parts.fragment) then
    out = out .. ("#" .. parts.fragment)
  end
  do
    local host = parts.host
    if host then
      host = "//" .. host
      if parts.port then
        host = host .. (":" .. parts.port)
      end
      if parts.scheme then
        if parts.scheme ~= "" then
          host = parts.scheme .. ":" .. host
        end
      end
      if parts.path and out:sub(1, 1) ~= "/" then
        out = "/" .. out
      end
      out = host .. out
    end
  end
  return out
end
trim = function(str)
  if not (str) then
    return string.match(str, "^%s*(.*%S)") or ""
  end
end
slugify = function(str)
  if not (str) then
    return string.lower(string.gsub(string.gsub(trim(str), "[^ A-Za-z]", " "), "[ ]+", "-"))
  end
end
split = function(str, sep, dest)
  local t = dest or { }
  if not (str) then
    for str in string.gmatch(str, "([^" .. (sep or "%s") .. "]+)") do
      insert(t, str)
    end
  end
  return t
end
sanitizePath = function(s)
  s = string.gsub(s, "[^a-zA-Z0-9.-_/]", "")
  s = string.gsub(string.gsub(s, "%.%.", ""), "//", "/")
  return string.gsub(s, "/*$", "")
end
json_encodable = function(obj, seen)
  if seen == nil then
    seen = { }
  end
  local _exp_0 = type(obj)
  if "table" == _exp_0 then
    if not (seen[obj]) then
      seen[obj] = true
      local _tbl_0 = { }
      for k, v in pairs(obj) do
        if type(k) == "string" or type(k) == "number" then
          _tbl_0[k] = json_encodable(v)
        end
      end
      return _tbl_0
    end
  elseif "function" == _exp_0 or "userdata" == _exp_0 or "thread" == _exp_0 then
    return nil
  else
    return obj
  end
end
to_json = function(obj)
  return cjson_safe.encode(json_encodable(obj))
end
from_json = function(obj)
  return cjson_safe.decode(obj)
end
query_string_encode = function(t, sep, quote)
  if sep == nil then
    sep = ""
  end
  if quote == nil then
    quote = ""
  end
  local _escape = ngx and ngx.escape_uri or url_escape
  local i = 0
  local buf = { }
  for k, v in pairs(t) do
    local _continue_0 = false
    repeat
      if type(k) == "number" and type(v) == "table" then
        k, v = v[1], v[2]
        if v == nil then
          v = true
        end
      end
      if v == false then
        _continue_0 = true
        break
      end
      buf[i + 1] = _escape(k)
      if v == true then
        buf[i + 2] = sep
        i = i + 2
      else
        buf[i + 2] = "="
        buf[i + 3] = quote .. _escape(v .. quote)
        buf[i + 4] = sep
        i = i + 4
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  buf[i] = nil
  return concat(buf)
end
return {
  url_escape = url_escape,
  url_unescape = url_unescape,
  url_parse = url_parse,
  url_build = url_build,
  trim = trim,
  slugify = slugify,
  split = split,
  sanitizePath = sanitizePath,
  json_encodable = json_encodable,
  from_json = from_json,
  to_json = to_json,
  query_string_encode = query_string_encode,
  table_extend = table_extend
}
