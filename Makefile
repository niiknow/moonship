
.PHONY: test local build global watch clean

test:
	busted spec
	busted spec_openresty

local: build
	luarocks make --force --local moonship-dev-1.rockspec

global: build
	sudo luarocks make moonship-dev-1.rockspec

build:
	moonc moonship
	moonc spec_openresty/s1

watch: build
	moonc -w moonship

clean:
	rm $$(find src/ | grep \.lua$$)
