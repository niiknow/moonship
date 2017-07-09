codecacher = require "moonship.codecacher"
plpath = require "path"
os.execute("mkdir -p \"" .. plpath.abs("./t/localhost") .. "\"")

describe "moonship.codecacher", ->

  it "myUrlHandler correctly request remote file", ->
    expected = 200
    opts = {
      url: "localhost/hello?yo=dawg",
      remote_path: "https://raw.githubusercontent.com/niiknow/moonship/master/remote"
    }

    res = codecacher.myUrlHandler(opts)
    assert.same expected, res.code

  it "require_new correctly request remote file", ->
    expected = "hello from github"
    res = codecacher.require_new("github.com/niiknow/moonship/tree/master/remote/localhost/hello/index.moon")
    assert.same expected, res.body

  it "CodeCacher correctly request and cache remote file", ->
    expected = "hello from github"
    opts = {
      app_path: plpath.abs("./t"),
      remote_path: "https://raw.githubusercontent.com/niiknow/moonship/master/remote",
      plugins: {
        request: require("moonship.plugins.request")
      }
    }
    opts.plugins.request.set({
      host: "localhost",
      path: "/hello"
    })
    cc = codecacher.CodeCacher(opts)
    res = cc\get()

    -- validate remote response
    assert.same expected, res.body

    -- validate local file cache exists
    f=io.open("#{opts.app_path}/localhost/hello/index.lua","r")
    assert.same true, f~=nil
    io.close(f)
