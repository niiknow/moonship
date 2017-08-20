package = "moonship"
version = "dev-1"

source = {
	url = "git://github.com/niiknow/moonship.git"
}

description = {
	summary = "A dynamic scripting framework with MoonScript",
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
	"lpeg"

}

build = {
	type = "builtin",
	modules = {
		["moonship"] = "lib/moonship/init.lua"
	}
}

