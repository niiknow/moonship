local http = require("moonship.http")
local aztm = require("moonship.aztablemagic")
local request = require("moonship.plugins.request")
local util = require("moonship.util")
local aztable, azauth
aztable, azauth = aztm.aztable, aztm.azauth
local from_json, to_json
from_json, to_json = util.from_json, util.to_json
local get
get = function(k)
  local opts = opts_cache_get({
    table_name = "storage",
    cache_key = k
  })
  local res = http.request(opts)
  if not (res.body) then
    return nil, tostring(k) .. " not found"
  end
  return from_json(res.body).value
end
local set
set = function(k, v)
  local vt = type(v)
  if (v == "function") then
    v = pcall(v)
  end
  vt = type(v)
  if not (vt == "string") then
    return nil, "value must be string"
  end
  local opts = opts_cache_set({
    table_name = "storage",
    cache_ttl = ttl or 600,
    cache_key = k,
    cache_value = v
  })
  opts.body = to_json(opts.item)
  local res = http.request(opts)
  return v
end
return {
  get = get,
  set = set
}
