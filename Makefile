VERSION          = 0.3.4
OPENRESTY_PREFIX = /usr/local/openresty
PREFIX          ?= /usr/local
LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_LIB_DIR     ?= $(PREFIX)/lib/lua/$(LUA_VERSION)
INSTALL         ?= install

.PHONY: all install test build local global test-spec clean doc

all: build ;

install: all
	$(INSTALL) -d $(LUA_LIB_DIR)/moonship
	$(INSTALL) lib/moonship/*.* $(LUA_LIB_DIR)/moonship
	$(INSTALL) -d $(LUA_LIB_DIR)/moonship/nginx
	$(INSTALL) lib/moonship/nginx/*.* $(LUA_LIB_DIR)/moonship/nginx
	$(INSTALL) -d $(LUA_LIB_DIR)/moonship/resty
	$(INSTALL) lib/moonship/resty/*.* $(LUA_LIB_DIR)/moonship/resty
	$(INSTALL) -d $(LUA_LIB_DIR)/moonship/vendor
	$(INSTALL) lib/moonship/vendor/*.* $(LUA_LIB_DIR)/moonship/vendor

test-resty: all
	PATH=$(OPENRESTY_PREFIX)/nginx/sbin:$$PATH prove -I../test-nginx/lib -r t

build:
	cd lib && $(MAKE) build

local: build
	luarocks make --force --local moonship-git-1.rockspec

global: build
	sudo luarocks make moonship-git-1.rockspec

test:
	cd lib && $(MAKE) test

clean:
	rm -rf doc/
	rm -rf t/servroot/
	cd lib && $(MAKE) clean

init:
	cd lib && $(MAKE) init

doc:
	cd lib && $(MAKE) doc

upload:
	@rm -f *-0.**.rockspec*
	@sed -e "s/master/$(VERSION)/g" moonship-master-1.rockspec > moonship-$(VERSION)-1.rockspec
	@echo "luarocks upload moonship-$(VERSION)-1.rockspec --api-key=?"
