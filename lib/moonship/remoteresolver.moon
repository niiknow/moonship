util        = require "moonship.url"
httpc       = require "moonship.http"

import url_parse, trim from util

loadCode = (url) ->
  req = { url: url, method: "GET", capture_url: "/__libpublic", headers: {} }
  res, err = httpc.request(req)

  return res unless err

  { code: 0, body: err }

resolve_remote = (modname) ->
  parsed = url_parse modname
  parsed.basepath, parsed.file = string.match(parsed.path, "^(.*/)([^/]*)$")
  parsed

-- attempt to parse and store new basepath
resolve_github = (modname) ->
  modname = modname\gsub("github%.com/", "https://raw.githubusercontent.com/")
  parsed = resolve_remote(modname)
  user, repo, tree, branch, rest = string.match(parsed.basepath, "([^/]+)(/[^/]+)(/[^/]+)(/[^/]+)(.*)")
  parsed.basepath =  "#{user}#{repo}#{branch}#{rest}"
  parsed.path = "#{parsed.pathx}#{parsed.file}"
  parsed

resolve = (modname) ->
  modname = (modname)
  rst = {}

  -- remote is a url, then parse the url
  rst = resolve_remote(modname) if modname\find("http") == 1

  -- if github, then parse and store new basepath
  rst = resolve_github(modname) if modname\find("github%.com/") == 1

  -- if _remotebase, parse relative to it
  remotebase = _G["_remotebase"]
  if remotebase
    remotemodname = "#{remotebase}/#{modname}"
    rst = resolve_remote(remotemodname) if remotemodname\find("http") == 1

  return { path: modname } unless rst.path

  -- remove .moon extension to convert period to forward slash
  -- then add back moon extension
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
