
.PHONY: test local build global watch clean

test: build
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
	sudo luarocks install lua-lru
	sudo luarocks install lpath
	sudo luarocks install luasec OPENSSL_DIR=/usr/local/opt/openssl
	sudo luarocks install cqueues CRYPTO_DIR=/usr/local/opt/openssl OPENSSL_DIR=/usr/local/opt/openssl
	sudo luarocks install http CRYPTO_DIR=/usr/local/opt/openssl OPENSSL_DIR=/usr/local/opt/openssl
	sudo luarocks install mooncrafts

doc: clean
	ldoc .
