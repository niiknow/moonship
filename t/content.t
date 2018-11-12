use Test::Nginx::Socket;
use Cwd qw(cwd);

plan tests => repeat_each() * (blocks() * 4);

my $pwd = cwd();

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';
$ENV{TEST_COVERAGE} ||= 0;
$ENV{MOONSHIP_APP_PATH} = 't/servroot/html';

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;/usr/local/share/lua/5.1/?.lua;;";
    error_log logs/error.log debug;

    init_by_lua_block {
        if $ENV{TEST_COVERAGE} == 1 then
            jit.off()
            require("luacov.runner").init()
        end
    }

    resolver $ENV{TEST_NGINX_RESOLVER};
};

no_long_string();

run_tests();

__DATA__
=== TEST 1: aws s3 file
--- main_config
  env AWS_S3_KEY_ID;
  env AWS_S3_ACCESS_KEY;
  env AWS_S3_PATH;
  env MOONSHIP_APP_PATH;

--- http_config eval: $::HttpConfig
--- config
  location = /hello {
  	content_by_lua_file ../../lib/moonship/nginx/content.lua;
  }

  location /__proxy {
		internal;
		set_unescape_uri               	$clean_url "$arg_target";

		proxy_pass                     	$clean_url;
		proxy_cache_key                	$clean_url;

		# small cache to help prevent hammering of backend
		proxy_cache_valid              	any 10s;
	}

  location /__private {
		internal;
		set_unescape_uri               	$clean_url "$arg_target";

		proxy_pass                     	$clean_url;
		proxy_cache_key                	$clean_url;

		# small cache to help prevent hammering of backend
		proxy_cache_valid              	any 10s;
  }
--- request
GET /hello
--- response_body
hello from s3
--- no_error_log
[error]
[warn]

