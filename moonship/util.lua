local url = require("socket.url")
local cjson_safe = require("cjson.safe")
local moonscript = require("moonscript.base")
local concat, insert
do
  local _obj_0 = table
  concat, insert = _obj_0.concat, _obj_0.insert
end
local url_unescape, url_escape, url_parse, url_build, trim, path_sanitize, slugify, split, json_encodable, from_json, to_json, query_string_encode, resolveGithubRaw, loadstring
url_unescape = function(str)
  return url.unescape(str)
end
url_escape = function(str)
  return url.escape(str)
end
url_parse = function(str)
  return url.parse(str)
end
url_build = function(parts, includeQuery)
  if includeQuery == nil then
    includeQuery = true
  end
  local out = parts.path or ""
  if includeQuery then
    if parts.query then
      out = out .. ("?" .. parts.query)
    end
    if parts.fragment then
      out = out .. ("#" .. parts.fragment)
    end
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
trim = function(str, regex)
  if regex == nil then
    regex = "%s*"
  end
  str = tostring(str)
  if #str > 200 then
    return str:gsub("^" .. tostring(regex), ""):reverse():gsub("^" .. tostring(regex), ""):reverse()
  else
    return str:match("^" .. tostring(regex) .. "(.-)" .. tostring(regex) .. "$")
  end
end
path_sanitize = function(str)
  str = tostring(str)
  return str:gsub("[^a-zA-Z0-9.-_/]", ""):gsub("%.%.+", ""):gsub("//+", "/")
end
slugify = function(str)
  str = tostring(str)
  return (str:gsub("[%s_]+", "-"):gsub("[^%w%-]+", ""):gsub("-+", "-")):lower()
end
split = function(str, sep, dest)
  if dest == nil then
    dest = { }
  end
  str = tostring(str)
  for str in string.gmatch(str, "([^" .. (sep or "%s") .. "]+)") do
    insert(dest, str)
  end
  return dest
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
from_json = function(obj)
  return cjson_safe.decode(obj)
end
to_json = function(obj)
  return cjson_safe.encode(json_encodable(obj))
end
query_string_encode = function(t, sep, quote)
  if sep == nil then
    sep = "&"
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
        buf[i + 3] = quote .. (_escape(v)) .. quote
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
resolveGithubRaw = function(modname)
  local capturePath = "https://raw.githubusercontent.com/"
  if string.find(modname, "github.com/") then
    local user, repo, branch, pathx, query = string.match(modname, "github%.com/([^/]+)(/[^/]+)/blob(/[^/]+)(/[^?#]*)(.*)")
    local path, file = string.match(pathx, "^(.*/)([^/]*)$")
    local base = string.format("%s%s%s%s%s", capturePath, user, repo, branch, path)
    return base, string.gsub(string.gsub(file, "%.moon$", ""), '%.', "/") .. ".moon", query
  end
  return __ghrawbase, string.gsub(string.gsub(modname, "%.moon$", ""), '%.', "/") .. ".moon", ""
end
loadstring = function(code)
  return moonscript.loadstring('print "hi!"')
end
return {
  url_escape = url_escape,
  url_unescape = url_unescape,
  url_parse = url_parse,
  url_build = url_build,
  trim = trim,
  path_sanitize = path_sanitize,
  slugify = slugify,
  split = split,
  json_encodable = json_encodable,
  from_json = from_json,
  to_json = to_json,
  query_string_encode = query_string_encode
}
