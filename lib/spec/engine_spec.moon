engine = require "moonship.engine"
plpath = require "path"

describe "moonship.engine", ->

  it "successfully engage engine", ->
    expected = "hello from github"
    opts = {
      app_path: plpath.abs('./t'),
      remote_path: 'https://raw.githubusercontent.com/niiknow/moonship/master/remote'
    }
    ngin = engine(opts)
    res = ngin\engage({host: 'localhost', path: '/hello'})

    assert.same expected, res.body

  it "fail engage engine with bad path", ->
    expected = 404
    opts = {
      app_path: plpath.abs('./t'),
      remote_path: 'https://raw.githubusercontent.com/niiknow/moonship/master/remote'
    }
    ngin = engine(opts)
    res = ngin\engage({host: 'localhost', path: '/world'})

    assert.same expected, res.code
