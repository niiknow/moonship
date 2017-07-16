aztable     = require "moonship.aztable"
util        = require "moonship.util"
log         = require "moonship.log"
asynclogger = require "moonship.asynclogger"

import string_connection_parse, string_random, to_json from util

import string_connection_parse from util

describe "moonship.asynclogger", ->
  it "dolog should successfully write remote log", ->
    azure_storage = os.getenv("AZURE_STORAGE")

    if (azure_storage)
      logger = asynclogger()
      -- do async logger
      rsp = {code: 0, body: 'test', req: { start: 0, end: 0, host: 'unit.test', path: "/asynclogger", logs: {"unit", "test"} }}
      res = logger\dolog(rsp)
      assert.same 201, res.code

