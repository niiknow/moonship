
util = require "moonship.util"
json = require "cjson"

tests = {
  {
    ->
      util.url_escape "fly me=to"

    "fly%20me%3dto"
  }

  {
    ->
      util.url_unescape "fly%20me%3dto"

    "fly me=to"
  }

  {
    ->
      util.url_parse "https://example.com:443/hello/?cruel=world#yes"

    {
      "authority": 'example.com:443',
      "fragment": 'yes',
      "host": 'example.com',
      "path": '/hello/',
      "port": '443',
      "query": 'cruel=world',
      "scheme": 'https'
    }
  }

  {
    ->
      util.url_build {
        "authority": 'example.com:443',
        "fragment": 'yes',
        "host": 'example.com',
        "path": '/hello/',
        "port": '443',
        "query": 'cruel=world',
        "scheme": 'https'
      }

    "https://example.com:443/hello/?cruel=world#yes"
  }

  {
    -> util.trim "ho ly    cow"
    "ho ly    cow"
  }

  {
    -> util.trim "
      blah blah          "
    "blah blah"
  }

  {
    -> util.trim "   hello#{" "\rep 20000}world "
    "hello#{" "\rep 20000}world"
  }


  {
    -> util.path_sanitize "tHis//is Some///crazy./../path//?asdf"
    "tHis/isSome/crazy./path/?asdf"
  }

  {
    -> util.slugify "What is going on right now?"
    "what-is-going-on-right-now"
  }

  {
    -> util.slugify "whhaa  $%#$  hooo"
    "whhaa-hooo"
  }

  {
    -> util.slugify "what-about-now"
    "what-about-now"
  }

  {
    -> util.slugify "hello - me"
    "hello-me"
  }

  {
    -> util.slugify "cow _ dogs"
    "cow-dogs"
  }


  {
    ->
      util.from_json '{"color": "blue", "data": { "height": 10 }}'

    {
      color: "blue", data: { height: 10}
    }
  }

  { -- stripping invalid types
    ->
      json.decode util.to_json {
        color: "blue"
        data: {
          height: 10
          fn: =>
        }
      }

    {
      color: "blue", data: { height: 10}
    }
  }

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

