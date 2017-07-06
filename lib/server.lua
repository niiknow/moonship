print(package.path)
print(package.cpath)
package.path = package.path .. ";lib/?.lua"
local engine = require("moonship.engine")
local plpath = require("path")
local log = require("moonship.log")
log.level(log.DEBUG)
local port = 4000
local http_server = require("http.server")
local http_headers = require("http.headers")
local myopts = { }
local reply
reply = function(myserver, stream)
  local req_headers = assert(stream:get_headers())
  local req = {
    method = req_headers:get(":method" or "GET"),
    headers = req_headers,
    path = req_headers:get(":path") or "",
    version = stream.connection.version,
    referer = req_headers:get("referer") or "-",
    user_agent = req_headers:get("user-agent") or "-",
    host = "localhost"
  }
  log.write({
    os.date("%d/%b/%Y:%H:%M:%S %z"),
    req.method,
    req.path,
    req.version,
    req.version,
    req.referer,
    req.user_agent
  })
  local ngin = engine.Engine(myopts)
  local rst = ngin:engage(req)
  local res_headers = http_headers.new()
  res_headers:append(":status", tostring(rst.code))
  for k, v in pairs(rst.headers) do
    res_headers:append(k, v)
  end
  assert(stream:write_headers(res_headers, req.method == "HEAD"))
  if req.method ~= "HEAD" and rst.body then
    return assert(stream:write_chunk(rst.body, true))
  end
end
local runserver
runserver = function(opts)
  myopts = opts
  local myserver = http_server.listen({
    host = "localhost",
    port = port,
    onstream = reply
  })
  assert(myserver:listen())
  local bound_port = select(3, myserver:localname())
  assert(io.stderr:write(string.format("Now listening on port %d\n", bound_port)))
  return assert(myserver:loop())
end
return runserver({
  app_path = plpath.abs('./t'),
  remote_path = "https://raw.githubusercontent.com/niiknow/moonship/master/remote"
})
