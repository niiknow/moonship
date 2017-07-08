OPENRESTY_PREFIX=/usr/local/openresty

PREFIX ?=          /usr/local
LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_LIB_DIR ?=     $(PREFIX)/lib/lua/$(LUA_VERSION)
INSTALL ?= install

.PHONY: all test test-moon install build

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

test:
	cd lib && $(MAKE) test
