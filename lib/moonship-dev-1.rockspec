package = "moonship"
version = "dev-1"

source = {
	url = "git://github.com/niiknow/moonship.git"
}

description = {
	summary = "A dynamic scripting framework for MoonScript",
	homepage = "https://niiknow.github.io/moonship",
	maintainer = "Tom Noogen <friends@niiknow.org>",
	license = "MIT"
}

dependencies = {
	"lua ~> 5.1",

	"ansicolors",
	"date",
	"etlua",
	"loadkit",
	"lpeg",
	"lua-cjson",
	"luacrypto",
	"luafilesystem",
	"luasocket",
	"mimetypes",

  "bcrypt",
  "luacrypto",
  "md5",
  "penlight",
  "lua-resty-http",
  "lua-resty-string",
  "lua-lru",
  "lua-resty-hmac",
  "lua-resty-jwt"
}

build = {
	type = "builtin",
	modules = {
		["moonship"] = "lib/moonship/init.lua"
	}
}
