config = require "moonship.config"

log               = require "moonship.log"
log.set_lvl("info")

engine            = require "moonship.engine"
awsauth           = require "moonship.awsauth"
azts              = require "moonship.aztablestategy"
util              = require "moonship.util"
crypto            = require "moonship.crypto"
hmacauth          = require "moonship.hmacauth"
http              = require "moonship.http"
logger            = require "moonship.log"
oauth1            = require "moonship.oauth1"
requestbuilder    = require "moonship.requestbuilder"

import table_clone from util

describe "moonship.config", ->

  it "config require can perform deep path resolution", ->
    opts =  {
      requestbuilder: requestbuilder,
      plugins: {}
    }
    conf = config(opts)
    cf = conf\get()
    homer, err = cf.plugins.require("github.com/niiknow/moonship/tree/master/remote/simpson/homer.moon")
    rst = homer

    assert.same true, rst
