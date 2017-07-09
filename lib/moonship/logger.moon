-- implement singleton log

logger = require "log"
list_writer = require "log.writer.list"
console_color = require "log.writer.console.color"
cjson_safe       = require "cjson.safe"
to_json = cjson_safe.decode

doformat = (p) ->
  if type(p) == 'table'
    return to_json p

  if p == nil
    return "nil"

  tostring(p)

sep = ' '

formatter = (...) ->
  argc,argv = select('#', ...), {...}

  for i = 1, argc do argv[i] = doformat(argv[i])

  table.concat(argv, sep)

local *

log = logger.new( "info", list_writer.new( console_color.new() ), formatter )

log
