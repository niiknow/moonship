
util = require "moonship.util"
log = require "moonship.log"

aws_region            = os.getenv("AWS_DEFAULT_REGION")
aws_access_key_id     = os.getenv("AWS_ACCESS_KEY_ID")
aws_secret_access_key = os.getenv("AWS_SECRET_ACCESS_KEY")
aws_s3_code_path      = os.getenv("AWS_S3_CODE_PATH") -- 'bucket-name/basepath'
app_path              = os.getenv("MOONSHIP_APP_PATH")

code_cache_size       = os.getenv("MOONSHIP_CODE_CACHE_SIZE")
remote_path           = os.getenv("MOONSHIP_REMOTE_PATH")

table_deepclone       = util.table_deepclone

_data = {}

class Config
  new: (newOpts={ aws_region: 'us-east-1', code_cache_size: 10000 }) =>
    defaultOpts = {:aws_region, :aws_access_key_id, :aws_secret_access_key, :aws_s3_code_path, :app_path, :code_cache_size, :remote_path }

    util.applyDefaults(newOpts, defaultOpts)

    _data = newOpts

  get: () => table_deepclone(_data)

{ :Config }
