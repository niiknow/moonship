-- local web server for debugging purpose only

port = 4000
http_server = require "http.server"
http_headers = require "http.headers"

reply = (myserver, stream) ->
  -- Read in headers
  req_headers = assert(stream\get_headers())
  req = {
    method: req_headers\get ":method" or "GET",
    headers: req_headers
    path: req_headers\get(":path") or "",
    version: stream.connection.version,
    referer: req_headers\get("referer") or "-",
    user_agent: req_headers\get("user-agent") or "-"
  }

  -- Log request to stdout
  assert(io.stdout\write(string.format('[%s] "%s %s HTTP/%g"  "%s" "%s"\n',
    os.date("%d/%b/%Y:%H:%M:%S %z"),
    req.method,
    req.path,
    req.version,
    req.version,
    req.referer,
    req.user_agent
  )))

  -- Build response headers
  res_headers = http_headers.new()
  res_headers\append(":status", "200")
  res_headers\append("content-type", "text/plain")
  -- Send headers to client; end the stream immediately if this was a HEAD request
  assert(stream:write_headers(res_headers, req.method == "HEAD"))
  if req.method  ~= "HEAD"
    -- Send body, ending the stream
    assert(stream:write_chunk("Hello world!\n", true))


myserver = http_server.listen {
  host: "localhost",
  port: port,
  onstream: reply
}

-- Manually call :listen() so that we are bound before calling :localname()
assert(myserver:listen())
bound_port = select(3, myserver:localname())
assert(io.stderr\write(string.format("Now listening on port %d\n", bound_port)))

-- Start the main server loop
assert(myserver:loop())
