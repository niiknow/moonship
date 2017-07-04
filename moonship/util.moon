
url        = require "socket.url"
cjson_safe = require "cjson.safe"

import concat, insert, sort from table

-- our utils lib, nothing here should depend on ngx
-- for ngx stuff, put it inside ngin.lua file
local *

url_unescape = (str) -> url.unescape(str)

url_escape = (str) -> url.escape(str)

url_parse = (str) -> url.parse(str)

-- {
--     [path] = "/test"
--     [scheme] = "http"
--     [host] = "localhost.com"
--     [port] = "8080"
--     [fragment] = "!hash_bang"
--     [query] = "hello=world"
-- }
url_build = (parts, includeQuery=true) ->
  out = parts.path or ""
  if includeQuery
    out ..= "?" .. parts.query if parts.query
    out ..= "#" .. parts.fragment if parts.fragment

  if host = parts.host
    host = "//" .. host
    host ..= ":" .. parts.port if parts.port
    host = parts.scheme .. ":" .. host if parts.scheme and parts.scheme != ""
    out = "/" .. out if parts.path and out\sub(1,1) != "/"
    out = host .. out

  out


trim = (str, regex="%s*") ->
  str = tostring str

  if #str > 200
    str\gsub("^#{regex}", "")\reverse()\gsub("^#{regex}", "")\reverse()
  else
    str\match "^#{regex}(.-)#{regex}$"

path_sanitize = (str) ->
  str = tostring str
  -- path should not have double quote, single quote, period
  -- purposely left casing alone because paths are case-sensitive
  -- finally, remove double period and make single forward slash
  str\gsub("[^a-zA-Z0-9.-_/]", "")\gsub("%.%.+", "")\gsub("//+", "/")

slugify = (str) ->
  str = tostring str
  (str\gsub("[%s_]+", "-")\gsub("[^%w%-]+", "")\gsub("-+", "-"))\lower!

string_split = (str, sep, dest={}) ->
  str = tostring str
  for str in string.gmatch(str, "([^" .. (sep or "%s") .. "]+)") do
    insert(dest, str)

  dest

json_encodable = (obj, seen={}) ->
  switch type obj
    when "table"
      unless seen[obj]
        seen[obj] = true
        { k, json_encodable(v) for k,v in pairs(obj) when type(k) == "string" or type(k) == "number" }
    when "function", "userdata", "thread"
      nil
    else
      obj

from_json = (obj) -> cjson_safe.decode obj

to_json = (obj) -> cjson_safe.encode (json_encodable obj)

encodeURIComponent = (s) ->
  m = (c) -> string.format("%%%02X", string.byte(c))
  s = string.gsub(s, "([&=+%c])", m)
  s = string.gsub(s, " ", "%20")
  s

qsencode = (tab, sep="", q="") ->
  query = {}
  keys = {}
  for k in pairs(tab) do
    keys[#keys+1] = k

  sort(keys)
  for _,name in ipairs(keys) do
    value = tab[name]
    name = encodeURIComponent(tostring(name))

    value = encodeURIComponent(tostring(value))
    if value ~= "" then
      query[#query+1] = string.format('%s=%s', name, q .. value .. q)
    else
      query[#query+1] = name


  concat(query, sep)

query_string_encode = (t, sep="&", quote="") ->
  _escape = ngx and ngx.escape_uri or url_escape

  i = 0
  buf = {}
  for k,v in pairs t
    if type(k) == "number" and type(v) == "table"
      {k,v} = v
      v = true if v == nil -- symmetrical with parse

    if v == false
      continue

    buf[i + 1] = _escape k
    if v == true
      buf[i + 2] = sep
      i += 2
    else
      buf[i + 2] = "="
      buf[i + 3] = quote .. (_escape v) .. quote
      buf[i + 4] = sep
      i += 4

  buf[i] = nil
  concat buf

resolveGithubRaw = (modname) ->
  capturePath = "https://raw.githubusercontent.com/"
  if string.find(modname, "github.com/")
    user, repo, branch, pathx, query = string.match(modname, "github%.com/([^/]+)(/[^/]+)/tree(/[^/]+)(/[^?#]*)(.*)")
    path, file = string.match(pathx, "^(.*/)([^/]*)$")
    base = string.format("%s%s%s%s%s", capturePath, user, repo, branch, path)

    -- convert period to folder before return
    return base, string.gsub(string.gsub(file, "%.moon$", ""), '%.', "/") .. ".moon", query

  __ghrawbase, string.gsub(string.gsub(modname, "%.moon$", ""), '%.', "/") .. ".moon", ""

applyDefaults = (opts, defOpts) ->
  for k, v in pairs(defOpts) do
    opts[k] = v unless opts[k]
  opts

{ :url_escape, :url_unescape, :url_parse, :url_build,
  :trim, :path_sanitize, :slugify, :string_split,
  :json_encodable, :from_json, :to_json, :encodeURIComponent, :qsencode
  :query_string_encode, :resolveGithubRaw, :applyDefaults
}
