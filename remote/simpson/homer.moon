bart = require "children.bart"
lisa = require "children.lisa"

msg = "#{bart.say}\n"
msg ..= "#{lisa.say}\n"

{ code: 200, body: msg}
