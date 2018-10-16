OPENRESTY_PREFIX=/usr/local/openresty

PREFIX ?=          /usr/local
LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_LIB_DIR ?=     $(PREFIX)/lib/lua/$(LUA_VERSION)
INSTALL ?= install

.PHONY: all test test-moon install build local global doc

all: build ;

install: all
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/moonship
	$(INSTALL) lib/moonship/*.* $(DESTDIR)/$(LUA_LIB_DIR)/moonship
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/moonship/plugins
	$(INSTALL) lib/moonship/plugins/*.* $(DESTDIR)/$(LUA_LIB_DIR)/moonship/plugins
	$(INSTALL) -d $(DESTDIR)/$(LUA_LIB_DIR)/moonship/nginx
	$(INSTALL) lib/moonship/nginx/*.* $(DESTDIR)/$(LUA_LIB_DIR)/moonship/nginx

test-resty: all
	PATH=$(OPENRESTY_PREFIX)/nginx/sbin:$$PATH prove -I../test-nginx/lib -r t

build:
	cd lib && $(MAKE) build

local: build
	luarocks make --force --local mooncrafts-git-1.rockspec

global: build
	sudo luarocks make mooncrafts-git-1.rockspec

test:
	cd lib && $(MAKE) test

clean:
	rm -rf doc/
	cd lib && $(MAKE) clean

init:
	cd lib && $(MAKE) init

doc:
	cd lib && $(MAKE) doc

