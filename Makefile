
.PHONY: test local build global watch clean

test:
	busted spec

local: build
	luarocks make --force --local moonship-dev-1.rockspec

global: build
	sudo luarocks make moonship-dev-1.rockspec

build:
	moonc moonship

watch: build
	moonc -w moonship

clean:
	rm $$(find src/ | grep \.lua$$)
