local logger = require("log")
local list_writer = require("log.writer.list")
local console_color = require("log.writer.console.color")
local cjson_safe = require("cjson.safe")
local to_json = cjson_safe.decode
local doformat
doformat = function(p)
  if type(p) == 'table' then
    return to_json(p)
  end
  if p == nil then
    return "nil"
  end
  return tostring(p)
end
local sep = ' '
local formatter
formatter = function(...)
  local argc, argv = select('#', ...), {
    ...
  }
  for i = 1, argc do
    argv[i] = doformat(argv[i])
  end
  return table.concat(argv, sep)
end
local log
log = logger.new("info", list_writer.new(console_color.new()), formatter)
return log
