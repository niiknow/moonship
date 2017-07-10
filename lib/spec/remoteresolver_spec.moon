remoteresolver = require "moonship.remoteresolver"

describe "moonship.remoteresolver", ->

  it "correctly resolve_remote url", ->
    expected = {
      "authority": 'github.com'
      "basepath": '/niiknow/moonship/blob/master/lib/moonship'
      "file": 'remoteresolver.moon'
      "host": 'github.com'
      "path": '/niiknow/moonship/blob/master/lib/moonship/remoteresolver.moon'
      "port": '443'
      "scheme": 'https'
      "fragment": '!yep'
      "query": "hello=worl%20d"
    }
    actual = remoteresolver.resolve_remote("https://github.com/niiknow/moonship/blob/master/lib/moonship/remoteresolver.moon?hello=worl%20d#!yep")
    assert.same expected, actual


  it "correctly resolve_github url", ->
    expected = {
      "authority": 'raw.githubusercontent.com'
      "basepath": '/niiknow/moonship/master/lib/moonship'
      "file": 'remoteresolver.moon'
      "host": 'raw.githubusercontent.com'
      "path": '/niiknow/moonship/master/lib/moonship/remoteresolver.moon'
      "github": true
      "port": '443'
      "scheme": 'https'
      "fragment": '!yep'
      "query": "hello=worl%20d"
    }
    actual = remoteresolver.resolve_github("github.com/niiknow/moonship/blob/master/lib/moonship/remoteresolver.moon?hello=worl%20d#!yep")
    assert.same expected, actual


  it "correctly resolve with _remotebase", ->
    _G["_remotebase"] = "http://noogen.net"
    expected = {
      "_remotebase": 'http://noogen.net'
      "authority": 'noogen.net'
      "basepath": 'http://noogen.net:80/'
      "file": 'remoteresolver.moon'
      "host": 'noogen.net'
      "path": '/remoteresolver.moon'
      "port": '80'
      "scheme": 'http',
      "fragment": '!yep',
      "query": "hello=worl%20d"
    }
    actual = remoteresolver.resolve("remoteresolver.moon?hello=worl%20d#!yep")
    actual.codeloader = nil
    _G["_remotebase"] = nil
    assert.same expected, actual
