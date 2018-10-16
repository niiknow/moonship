config = require "moonship.config"

log               = require "mooncrafts.log"
log.set_lvl("info")

engine            = require "moonship.engine"
awsauth           = require "mooncrafts.awsauth"
util              = require "mooncrafts.util"
crypto            = require "mooncrafts.crypto"
hmacauth          = require "mooncrafts.hmacauth"
http              = require "mooncrafts.http"
logger            = require "mooncrafts.log"
oauth1            = require "mooncrafts.oauth1"

import table_clone from util

describe "moonship.config", ->

  it "config require can perform deep path resolution", ->
    expected = "Bart: Ay, caramba!\nLisa: Do you even know what that means?\nMarge: Lisa, your food is getting cold.\n"
    opts =  {
      plugins: {}
    }
    conf = config(opts)
    cf = conf\get()
    homer, err = cf.plugins.require("github.com/niiknow/moonship/tree/master/remote/simpson/homer.moon")
    rst = homer!
    assert.same expected, rst.body
    actual = homer! -- call two times to see if it actually reload other modules
    assert.same expected, actual.body

