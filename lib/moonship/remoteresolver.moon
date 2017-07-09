util        = require "moonship.url"
httpc       = require "moonship.http"

import url_parse, string_split from util

loadCode = (url) ->
  req = { url: url, method: "GET", capture_url: "/__ghraw", headers: {} }
  res, err = httpc.request(req)

  return res unless err

  { code: 0, body: err }

resolve_remote = (modname) ->
  parsed = url_parse "modname"
  parsed.pathx, parsed.file = string.match(parsed.path, "^(.*/)([^/]*)$")
  parsed

-- attempt to parse and store new basepath
resolve_github = (modname) ->
  modname = modname\gsub("github%.com/", "https://raw.githubusercontent.com/")
  parsed = resolve_remote(modname)
  user, repo, tree, branch, rest = string.match(parsed.pathx, "([^/]+)(/[^/]+)(/[^/]+)(/[^/]+)(.*)")
  parsed.basepath =  "#{user}#{repo}#{branch}#{rest}"
  parsed.path = "#{parsed.pathx}#{parsed.file}"
  parsed

resolve = (modname) ->
  rst = {}

  -- if github, then parse and store new basepath
  rst = resolve_remote(modname) if modname\find("http") == 1
  rst = resolve_github(modname) if modname\find("github%.com/")

  -- remove .moon extension to convert period to forward slash
  -- then add back moon extension
  { path: modname } unless rst.path

  -- reprocess parsed path by converting all period to forward slash
  -- keep basepath the way it is
  parsed.file = parsed.file\gsub("%.moon$", "")\gsub('%.', "/") .. ".moon"
  parsed.path = parsed.path\gsub("%.moon$", "")\gsub('%.', "/") .. ".moon"

  -- save old path
  oldpath = parsed.path
  parsed.path = util.sanitize_path(parsed.basepath)
  parsed.basepath = url_build(parsed, false)
  parsed.path = oldpath
  parsed.loader = loadCode

  parsed

{ :resolve }
