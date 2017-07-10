util        = require "moonship.util"
httpc       = require "moonship.http"
log         = require "moonship.log"

import url_parse, trim, path_sanitize, url_build from util

loadcode = (url) ->
  req = { url: url, method: "GET", capture_url: "/__libpublic", headers: {} }
  res, err = httpc.request(req)

  return res unless err

  { code: 0, body: err }

resolve_remote = (modname) ->
  parsed = url_parse modname
  parsed.basepath, file = string.match(parsed.path, "^(.*)/([^/]*)$")
  parsed.file = trim(file, "/*") or ""
  parsed.basepath = "/" unless parsed.basepath
  parsed

-- attempt to parse and store new basepath
resolve_github = (modname) ->
  modname = modname\gsub("github%.com/", "https://raw.githubusercontent.com/")
  parsed = resolve_remote(modname)
  user, repo, blobortree, branch, rest = string.match(parsed.basepath, "(/[^/]+)(/[^/]+)(/[^/]+)(/[^/]+)(.*)")
  parsed.basepath = path_sanitize("#{user}#{repo}#{branch}#{rest}")
  parsed.path = "#{parsed.basepath}/#{parsed.file}"
  parsed

resolve = (modname) ->
  originalName = tostring(modname)\gsub("%.moon$", "")
  rst = {}

  -- remote is a url, then parse the url
  rst = resolve_remote(modname) if modname\find("http") == 1

  -- if github, then parse and store new basepath
  rst = resolve_github(modname) if modname\find("github%.com/") == 1

  -- if _remotebase, parse relative to it
  remotebase = _G["_remotebase"]
  firstp = originalName\find("%.")

  if remotebase ~= nil and firstp and rst.path == nil
    -- example: {url}/remote/simpson/homer.moon
    -- _remotebase: {url}/remote/simpson
    -- then: children.bart inside of homer would be -> /remote/simpson/children/bart.moon
    remotemodname = "#{remotebase}/#{modname}"
    rst = resolve_remote(remotemodname) if remotemodname\find("http") == 1
    rst._remotebase = remotebase

  return { path: modname } unless rst.path

  -- remove .moon extension to convert period to forward slash
  -- then add back moon extension
  -- reprocess rst path by converting all period to forward slash
  -- keep basepath the way it is
  rst.file = rst.file\gsub("%.moon$", "")\gsub('%.', "/") .. ".moon"
  rst.path = rst.path\gsub("%.moon$", "")\gsub('%.', "/") .. ".moon"

  -- save old path
  oldpath = rst.path
  rst.path = path_sanitize(rst.basepath)
  rst.basepath = url_build(rst, false)
  rst.path = oldpath
  rst.codeloader = loadcode

  -- no period in module original name means this is the basepath
  rst._remotebase = trim(rst.basepath, "/") unless originalName\find("%.")

  rst

{ :resolve, :resolve_github, :resolve_remote, :loadcode }
