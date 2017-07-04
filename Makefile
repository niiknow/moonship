
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
