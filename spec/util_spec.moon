
util = require "moonship.util"

tests = {
  {
    ->
      util.query_string_encode {
        {"first", "arg"}
        "hello[cruel]": "wor=ld"
      }

    "first=arg&hello%5bcruel%5d=wor%3dld"
  }

  {
    ->
      util.query_string_encode {
        {"cold", "day"}
        "in": true
        "hell": false
      }

    "cold=day&in"
  }

  {
    ->
      util.query_string_encode {
        "ignore_me": false
      }

    ""
  }

  {
    ->
      util.query_string_encode {
        "show_me": true
      }

    "show_me"
  }
}

describe "moonship.util", ->
  for group in *tests
    it "should match", ->
      input = group[1]!
      if #group > 2
        assert.one_of input, { unpack group, 2 }
      else
        assert.same input, group[2]

