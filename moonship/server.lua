local port = 4000
local http_server = require("http.server")
local http_headers = require("http.headers")
local reply
reply = function(myserver, stream)
  local req_headers = assert(stream:get_headers())
  local req = {
    method = req_headers:get(":method" or "GET"),
    headers = req_headers,
    path = req_headers:get(":path") or "",
    version = stream.connection.version,
    referer = req_headers:get("referer") or "-",
    user_agent = req_headers:get("user-agent") or "-"
  }
  assert(io.stdout:write(string.format('[%s] "%s %s HTTP/%g"  "%s" "%s"\n', os.date("%d/%b/%Y:%H:%M:%S %z"), req.method, req.path, req.version, req.version, req.referer, req.user_agent)))
  local res_headers = http_headers.new()
  res_headers:append(":status", "200")
  res_headers:append("content-type", "text/plain")
  assert({
    stream = write_headers(res_headers, req.method == "HEAD")
  })
  if req.method ~= "HEAD" then
    return assert({
      stream = write_chunk("Hello world!\n", true)
    })
  end
end
local myserver = http_server.listen({
  host = "localhost",
  port = port,
  onstream = reply
})
assert({
  myserver = listen()
})
local bound_port = select(3, {
  myserver = localname()
})
assert(io.stderr:write(string.format("Now listening on port %d\n", bound_port)))
return assert({
  myserver = loop()
})
