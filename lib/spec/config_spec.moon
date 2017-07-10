config = require "moonship.config"

log               = require "moonship.log"
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

describe "moonship.config", ->

  it "config require can perform deep path resolution", ->
    opts =  {
      requestbuilder: requestbuilder,
      plugins: {
        awsauth: awsauth,
        azauth: table_clone(azts.azauth),
        crypto: table_clone(crypto),
        hmacauth: table_clone(hmacauth),
        http: table_clone(http),
        oauth1: table_clone(oauth1),
        util: table_clone(util)
      }
    }
    conf = config(opts)
    cf = conf\get()
    homer = cf.require("https://github.com/niiknow/moonship/tree/master/remote/simpson/homer.moon")
