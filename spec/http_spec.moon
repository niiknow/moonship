http = require "moonship.http"

describe "moonship.http", ->

  it "correctly phone home", ->
    expected = 200
    opts = {
      url: "https://niiknow.github.io/"
    }
    rsp = http.request opts

    assert.same expected, rsp.code

  it "correctly access twitter", ->
    expected = 200
    oauth = {
      consumerkey: 'MdPcnDjJvYNOQrvKtYIhZyrpy',
      consumersecret: 'S6dqi2zA9ubMV09s9XrtfiMby4UOoAYEWcsHMZ5ZzCapenAx7I',
      accesstoken: '868641827821416449-SHePz3AENYMVFGy6BBj0ptd8ax58eAf',
      tokensecret: '8II6IKlX8tig0kfRSgXcN6UeAVOxhmDwcEMbkUyJeIKyz',
      timestamp: 1499196721
    }
    opts = {
      url: 'https://api.twitter.com/1.1/statuses/home_timeline.json?include_entities=true',
      oauth: oauth,
      headers: {"Accept-Encoding": "deflate"}
    }
    rsp = http.request opts

    assert.same "[]", rsp.body
