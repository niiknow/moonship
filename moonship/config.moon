
aws_region        = os.getenv("AWS_DEFAULT_REGION") or "us-east-1"
aws_access_key    = os.getenv("AWS_ACCESS_KEY_ID")
aws_secret_key    = os.getenv("AWS_SECRET_ACCESS_KEY")
aws_s3_code_path  = os.getenv("AWS_S3_CODE_PATH") -- 'bucket-name/basepath'
codecache_size    = os.getenv("MOONSHIP_CODECACHE_SIZE")
app_path          = os.getenv("MOONSHIP_APP_PATH")

class Config
  new: (newOpts={}) =>
    newOpts.aws_region = newOpts.aws_region or aws_region
    newOpts.aws_access_key = newOpts.aws_access_key or aws_access_key
    newOpts.aws_secret_key = newOpts.aws_secret_key or aws_secret_key
    newOpts.aws_s3_code_path = newOpts.aws_s3_code_path or aws_s3_code_path
    newOpts.codecache_size = newOpts.codecache_size or codecache_size
    newOpts.app_path = newOpts.app_path or app_path
    @data = newOpts

{
  :Config
}
