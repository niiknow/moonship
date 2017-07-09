local util = require("moonship.url")
local httpc = require("moonship.http")
local url_parse, string_split
url_parse, string_split = util.url_parse, util.string_split
local loadCode
loadCode = function(url)
  local req = {
    url = url,
    method = "GET",
    capture_url = "/__ghraw",
    headers = { }
  }
  local res, err = httpc.request(req)
  if not (err) then
    return res
  end
  return {
    code = 0,
    body = err
  }
end
local resolve_remote
resolve_remote = function(modname)
  local parsed = url_parse("modname")
  parsed.pathx, parsed.file = string.match(parsed.path, "^(.*/)([^/]*)$")
  return parsed
end
local resolve_github
resolve_github = function(modname)
  modname = modname:gsub("github%.com/", "https://raw.githubusercontent.com/")
  local parsed = resolve_remote(modname)
  local user, repo, tree, branch, rest = string.match(parsed.pathx, "([^/]+)(/[^/]+)(/[^/]+)(/[^/]+)(.*)")
  parsed.basepath = tostring(user) .. tostring(repo) .. tostring(branch) .. tostring(rest)
  parsed.path = tostring(parsed.pathx) .. tostring(parsed.file)
  return parsed
end
local resolve
resolve = function(modname)
  local rst = { }
  if modname:find("http") == 1 then
    rst = resolve_remote(modname)
  end
  if modname:find("github%.com/") then
    rst = resolve_github(modname)
  end
  if not (rst.path) then
    local _ = {
      path = modname
    }
  end
  parsed.file = parsed.file:gsub("%.moon$", ""):gsub('%.', "/") .. ".moon"
  parsed.path = parsed.path:gsub("%.moon$", ""):gsub('%.', "/") .. ".moon"
  local oldpath = parsed.path
  parsed.path = util.sanitize_path(parsed.basepath)
  parsed.basepath = url_build(parsed, false)
  parsed.path = oldpath
  parsed.loader = loadCode
  return parsed
end
return {
  resolve = resolve
}
