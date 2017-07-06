
cjson_safe       = require "cjson.safe"

local *

COLOR_DEBUG = "[0m[44m[37m DEBUG [0m[0m" -- blue
COLOR_INFO  = "[0m[42m[37m  INFO [0m[0m" -- green
COLOR_WARN  = "[0m[43m[30m  WARN [0m[0m" -- yellow
COLOR_ERROR = "[0m[41m[37m ERROR [0m[0m" -- red
COLOR_FATAL = "[0m[45m[37m FATAL [0m[0m" -- red blink

FATAL = 10
ERROR = 20
WARN = 30
INFO = 40
DEBUG = 50

printLogger = (level, ...) ->
  if ngx
    switch level
      when FATAL
        ngx.log(ngx.CRIT, ...)
      when ERROR
        ngx.log(ngx.ERR, ...)
      when WARN
        ngx.log(ngx.WARN, ...)
      when INFO
        ngx.log(ngx.INFO, ...)
      when DEBUG
        ngx.log(ngx.DEBUG, ...)

  else
    lvl = COLOR_INFO
    switch level
      when FATAL
        lvl = COLOR_FATAL
      when ERROR
        lvl = COLOR_ERROR
      when WARN
        lvl = COLOR_WARN
      when INFO
        lvl = COLOR_INFO
      when DEBUG
        lvl = COLOR_DEBUG

    print lvl, ...


class Log
  new: (log_level = INFO, loggers = { printLogger }) =>
    @loggers = loggers
    @log_level = log_level

  attachLogger: (lgr) =>
    @loggers[#@loggers+1] = lgr

  getLoggers: () =>
    @loggers

  doFormat: (p) =>
    if type(p) == 'table'
      return cjson_safe.encode p

    if p == nil
      return "nil"

    tostring(p)

  doLog: (req_level, level, ...) =>
    if req_level >= level
      params = [@doFormat(v) for v in *{...}]
      for _, logger in ipairs(@loggers)
        logger level, unpack params

  level: (ll) =>
    ll = DEBUG if type (ll) ~= "number" or ll > DEBUG
    ll = FATAL if ll < FATAL

    @log_level = ll

  fatal: (...) =>
    @doLog(@log_level, FATAL, ...)

  error: (...) =>
    @doLog(@log_level, ERROR, ...)

  warn: (...) =>
    @doLog(@log_level, WARN, ...)

  info: (...) =>
    @doLog(@log_level, INFO, ...)


  debug: (...) =>
    @doLog(@log_level, DEBUG, ...)

  write: (...) =>
    @info ...

Log
