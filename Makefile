
.PHONY: test local build global watch clean

test:
	busted -c spec

local: build
	luarocks make --force --local moonship-dev-1.rockspec

global: build
	sudo luarocks make moonship-dev-1.rockspec

build:
	moonc *.moon
	moonc moonship

watch: build
	moonc -w moonship

clean:
	rm $$(find src/ | grep \.lua$$)
	mkdir -p ./t/localhost
	rm -rf ./t/localhost

init:
	luarocks install busted
  luarocks install lpeg 0.10.2
  luarocks install moonscript
  luarocks install luaposix
  luarocks install date

  luarocks install luacrypto 0.3.2-2
  luarocks install http 0.2-0
  luarocks install bcrypt 2.1-4
  luarocks install md5 1.2-1
  luarocks install penlight 1.4.1
  luarocks install lua-resty-http 0.08-0
  luarocks install lua-lru 1.0-1
  luarocks install lua-resty-jwt 0.1.10-1
