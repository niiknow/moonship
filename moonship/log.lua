local logger = require("moonship.logger")
local log = logger()
return {
  FATAL = (function()
    local _base_0 = log
    local _fn_0 = _base_0.FATAL
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  ERROR = (function()
    local _base_0 = log
    local _fn_0 = _base_0.ERROR
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  WARN = (function()
    local _base_0 = log
    local _fn_0 = _base_0.WARN
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  INFO = (function()
    local _base_0 = log
    local _fn_0 = _base_0.INFO
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  DEBUG = (function()
    local _base_0 = log
    local _fn_0 = _base_0.DEBUG
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  fatal = (function()
    local _base_0 = log
    local _fn_0 = _base_0.fatal
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  error = (function()
    local _base_0 = log
    local _fn_0 = _base_0.error
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  warn = (function()
    local _base_0 = log
    local _fn_0 = _base_0.warn
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  info = (function()
    local _base_0 = log
    local _fn_0 = _base_0.info
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  debug = (function()
    local _base_0 = log
    local _fn_0 = _base_0.debug
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  write = (function()
    local _base_0 = log
    local _fn_0 = _base_0.write
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  level = (function()
    local _base_0 = log
    local _fn_0 = _base_0.level
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  attachLogger = (function()
    local _base_0 = log
    local _fn_0 = _base_0.attachLogger
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  getLoggers = (function()
    local _base_0 = log
    local _fn_0 = _base_0.getLoggers
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)(),
  doLog = (function()
    local _base_0 = log
    local _fn_0 = _base_0.doLog
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)()
}
