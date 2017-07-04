codecacher = require "moonship.codecacher"

describe "moonship.codecacher", ->

  it "myUrlHandler correctly request remote file", ->
    expected = 200
    opts = {
      url: 'localhost/hello?yo=dawg',
      remote_path: 'https://raw.githubusercontent.com/niiknow/moonship/master/remote'
    }

    res = codecacher.myUrlHandler(opts)
    assert.same expected, res.code

  it "require_new correctly request remote file", ->
    expected = "hello from github"
    res = codecacher.require_new("github.com/niiknow/moonship/tree/master/remote/localhost/hello/index.moon")
    assert.same expected, res.body

  it "CodeCacher correctly request and cache remote file", ->
    expected = "hello from github"
    res = codecacher.require_new("github.com/niiknow/moonship/tree/master/remote/localhost/hello/index.moon")
    assert.same expected, res.body
