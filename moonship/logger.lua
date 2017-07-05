local cjson_safe = require("cjson.safe")
local printLogger, COLOR_DEBUG, COLOR_TRACE, COLOR_INFO, COLOR_WARN, COLOR_ERROR, COLOR_FATAL, FATAL, ERROR, WARN, INFO, TRACE, DEBUG, Log
printLogger = function(...)
  return print(...)
end
COLOR_DEBUG = "[0m[44m[37m DEBUG [0m[0m"
COLOR_TRACE = "[0m[42m[37m TRACE [0m[0m"
COLOR_INFO = "[0m[30m[30m  INFO [0m[0m"
COLOR_WARN = "[0m[43m[30m  WARN [0m[0m"
COLOR_ERROR = "[0m[41m[37m ERROR [0m[0m"
COLOR_FATAL = "[0m[45m[37m[5m FATAL[0m[0m"
FATAL = 10
ERROR = 20
WARN = 30
INFO = 40
TRACE = 50
DEBUG = 60
do
  local _class_0
  local _base_0 = {
    attachLogger = function(self, lgr)
      self.loggers[#self.loggers + 1] = lgr
    end,
    getLoggers = function(self)
      return self.loggers
    end,
    doFormat = function(self, p)
      if type(p) == 'table' then
        return cjson_safe.decode(p)
      end
      if p == nil then
        return "nil"
      end
      return tostring(p)
    end,
    doLogInternal = function(self, ...)
      local params
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = {
          ...
        }
        for _index_0 = 1, #_list_0 do
          local v = _list_0[_index_0]
          _accum_0[_len_0] = self:doFormat(v)
          _len_0 = _len_0 + 1
        end
        params = _accum_0
      end
      for _, logger in ipairs(self.loggers) do
        logger(unpack(params))
      end
    end,
    doLog = function(self, req_level, level, ...)
      if req_level >= level then
        local lvl = "INFO"
        local _exp_0 = level
        if FATAL == _exp_0 then
          lvl = COLOR_FATAL
        elseif ERROR == _exp_0 then
          lvl = COLOR_ERROR
        elseif WARN == _exp_0 then
          lvl = COLOR_WARN
        elseif INFO == _exp_0 then
          lvl = COLOR_INFO
        elseif TRACE == _exp_0 then
          lvl = COLOR_TRACE
        elseif DEBUG == _exp_0 then
          lvl = COLOR_DEBUG
        else
          lvl = tostring(level)
        end
        return self:doLogInternal(lvl, ...)
      end
    end,
    level = function(self, ll)
      if type((ll) ~= "number" or ll > DEBUG) then
        ll = DEBUG
      end
      if ll < FATAL then
        ll = FATAL
      end
      self.log_level = ll
    end,
    fatal = function(self, ...)
      return self:doLog(self.log_level, FATAL, ...)
    end,
    error = function(self, ...)
      return self:doLog(self.log_level, ERROR, ...)
    end,
    warn = function(self, ...)
      return self:doLog(self.log_level, WARN, ...)
    end,
    info = function(self, ...)
      return self:doLog(self.log_level, INFO, ...)
    end,
    trace = function(self, ...)
      return self:doLog(self.log_level, TRACE, ...)
    end,
    debug = function(self, ...)
      return self:doLog(self.log_level, DEBUG, ...)
    end,
    write = function(self, ...)
      return self:info(...)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, log_level, loggers)
      if log_level == nil then
        log_level = INFO
      end
      if loggers == nil then
        loggers = {
          printLogger
        }
      end
      self.loggers = loggers
      self.log_level = log_level
    end,
    __base = _base_0,
    __name = "Log"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Log = _class_0
end
return Log
