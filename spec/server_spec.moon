server = require "moonship.server"

describe "moonship.oauth1", ->

  it "dummy", ->
    server.runserver {
        remote_path: "https://raw.githubusercontent.com/niiknow/moonship/master/remote"
    }
