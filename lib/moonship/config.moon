util                  = require "mooncrafts.util"

aws_region            = os.getenv("AWS_DEFAULT_REGION") or "us-east-1"
aws_access_key_id     = os.getenv("AWS_S3_KEY_ID")
aws_secret_access_key = os.getenv("AWS_S3_ACCESS_KEY")
aws_s3_path           = os.getenv("AWS_S3_PATH") -- 'bucket-name/basepath'

app_path              = os.getenv("MOONSHIP_APP_PATH")
app_env               = os.getenv("MOONSHIP_APP_ENV") or "PRD"

import string_split, table_clone, string_connection_parse from util
import insert from table
import upper from string

class Config
  new: (newOpts={}) =>
    defaultOpts = {
      :aws_region, :aws_access_key_id, :aws_secret_access_key, :aws_s3_path,
      :app_path, :remote_path, :app_env
    }

    util.applyDefaults(newOpts, defaultOpts)

    newOpts.alog = newOpts.azure_storage
    -- ngx.log(ngx.INFO, util.to_json(newOpts))

    newOpts.app_env = upper(newOpts.app_env or "PRD")
    @__data = newOpts

  get: () => table_clone(@__data, true) -- preserving config through cloning

Config
