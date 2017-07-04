
aws_region            = os.getenv("AWS_DEFAULT_REGION") or "us-east-1"
aws_access_key_id     = os.getenv("AWS_ACCESS_KEY_ID")
aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
aws_s3_code_path      = os.getenv("AWS_S3_CODE_PATH") -- 'bucket-name/basepath'
app_path              = os.getenv("MOONSHIP_APP_PATH")

code_cache_size       = os.getenv("MOONSHIP_CODE_CACHE_SIZE") or 10000
remote_path           = os.getenv("MOONSHIP_REMOTE_PATH")

util                  = require "moonship.util"
class Config
  new: (newOpts={}) =>
    defaultOpts = {:aws_region, :aws_access_key_id, :aws_secret_access_key, :aws_s3_code_path, :app_path, :code_cache_size, :remote_path }
    @data = util.applyDefaults(newOpts, defaultOpts)

{ :Config }
