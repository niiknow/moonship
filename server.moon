print(package.path) -- where .lua files are searched for
print(package.cpath) -- where native modules are searched for

-- add a new directory to the path
package.path = package.path .. ";lib/?.lua"

-- local web server demonstrates using github
engine = require "moonship.engine"
plpath = require "pl.path"
log = require "moonship.log"

log.level(log.DEBUG)

port = 4000
http_server = require "http.server"
http_headers = require "http.headers"
myopts = {}

reply = (myserver, stream) ->

  -- Read in headers
  req_headers = assert(stream\get_headers())
  req = {
    method: req_headers\get ":method" or "GET",
    headers: req_headers
    path: req_headers\get(":path") or "",
    version: stream.connection.version,
    referer: req_headers\get("referer") or "-",
    user_agent: req_headers\get("user-agent") or "-",
    host: "localhost"
  }

  log.write {
    os.date("%d/%b/%Y:%H:%M:%S %z"),
    req.method,
    req.path,
    req.version,
    req.version,
    req.referer,
    req.user_agent
  }

  ngin = engine.Engine(myopts)
  rst = ngin\engage(req)

  -- Build response headers
  res_headers = http_headers.new()
  res_headers\append(":status", tostring(rst.code))
  -- res_headers\append("content-type", rst.headers['Content-Type'])

  for k, v in pairs(rst.headers) do
    res_headers\append(k, v)

  -- Send headers to client; end the stream immediately if this was a HEAD request
  assert(stream\write_headers(res_headers, req.method == "HEAD"))

  if req.method  ~= "HEAD" and rst.body
    -- Send body, ending the stream
    assert(stream\write_chunk(rst.body, true))

local *
runserver = (opts) ->
  myopts = opts
  myserver = http_server.listen {
    host: "localhost",
    port: port,
    onstream: reply
  }

  -- Manually call :listen() so that we are bound before calling :localname()
  assert(myserver\listen())
  bound_port = select(3, myserver\localname())
  assert(io.stderr\write(string.format("Now listening on port %d\n", bound_port)))

  -- Start the main server loop
  assert(myserver\loop())

runserver  {
  app_path: plpath.abspath('./t'),
  remote_path: "https://raw.githubusercontent.com/niiknow/moonship/master/remote"
}
