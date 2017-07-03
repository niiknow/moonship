
url = require "socket.url"
cjson_safe = require "cjson.safe"

import concat, insert from table

-- our utils lib, nothing here should depend on ngx
-- for ngx stuff, put it inside ngin.lua file
local *

url_unescape = (str) ->
  url.unescape(str)

url_escape = (str) ->
  url.escape(str)

url_parse = (str) ->
  url.parse(str)

-- {
--     [path] = "/test"
--     [scheme] = "http"
--     [host] = "localhost.com"
--     [port] = "8080"
--     [fragment] = "!hash_bang"
--     [query] = "hello=world"
-- }
url_build = (parts) ->
  out = parts.path or ""
  unless parts.query
    out ..= "?" .. parts.query
  unless parts.fragment
    out ..= "#" .. parts.fragment

  if host = parts.host
    host = "//" .. host
    if parts.port
      host ..= ":" .. parts.port

    if parts.scheme
      if parts.scheme != ""
        host = parts.scheme .. ":" .. host

    if parts.path and out\sub(1,1) != "/"
      out = "/" .. out

    out = host .. out

  out

trim = (str) ->
  unless str
    string.match(str, "^%s*(.*%S)") or ""

slugify = (str) ->
  unless str
    string.lower(string.gsub(string.gsub(trim(str),"[^ A-Za-z]"," "),"[ ]+","-"))


split = (str, sep, dest) ->
  t = dest or {}

  unless str
    for str in string.gmatch(str, "([^" .. (sep or "%s") .. "]+)") do
      insert(t, str)
  t

sanitizePath = (s) ->
  -- path should not have double quote, single quote, period
  -- we purposely left casing because paths are case-sensitive
  s = string.gsub(s, "[^a-zA-Z0-9.-_/]", "")

  -- remove double period and forward slash
  s = string.gsub(string.gsub(s, "%.%.", ""), "//", "/")

  -- remove trailing forward slash which can always add later
  string.gsub(s, "/*$", "")

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

to_json = (obj) -> cjson_safe.encode json_encodable obj

from_json = (obj) -> cjson_safe.decode obj

query_string_encode = (t, sep="", quote="") ->
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
      buf[i + 3] = quote .. _escape v .. quote
      buf[i + 4] = sep
      i += 4

  buf[i] = nil
  concat buf

{ :url_escape, :url_unescape, :url_parse, :url_build
  :trim, :slugify, :split, :sanitizePath,
  :json_encodable, :from_json, :to_json,
  :query_string_encode, :table_extend
}
