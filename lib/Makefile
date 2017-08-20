
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

clean: build
	rm $$(find ./ | grep \.lua$$)
	rm -rf ./t/localhost
	mkdir -p ./t/localhost

init:
	luarocks install busted
	luarocks install lua-resty-jwt
	luarocks install lua-resty-http
	luarocks install moonscript
	luarocks install luacrypto
	luarocks install lua-lru
	luarocks install basexx
	luarocks install lpath
	luarocks install lua-log
	luarocks install --server=http://luarocks.org/dev ltn12
	luarocks install luasec 0.6-1
	luarocks install http

doc: clean
	ldoc .
