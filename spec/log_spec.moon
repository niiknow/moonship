log = require "moonship.log"

log.level(log.DEBUG)

describe "moonship.log", ->

  it "it should log to console", ->
    print "\n"
    log.debug "test"
    log.info "test"
    log.warn "test"
    log.error "test"
    log.fatal "test"
    print "\n"
