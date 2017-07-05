-- implement singleton log
logger = require "moonship.logger"
log = logger()

{
  FATAL: log\FATAL, ERROR: log\ERROR, WARN: log\WARN, INFO: log\INFO, TRACE: log\DEBUG, DEBUG: log\DEBUG,
  fatal: log\fatal, error: log\error, warn: log\warn, info: log\info, trace: log\trace, debug: log\debug,
  write: log\write, level: log\level, attachLogger: log\attachLogger, getLoggers: log\getLoggers, doLog: log\doLog
}
