-- derived from https://github.com/paragasu/lua-resty-aws-auth
-- modified to use our own crypto

crypto = require "moonship.crypto"
util = require "moonship.util"

class AwsAuth
  new: (options={}) =>
    microtime = os.time()

    options.aws_host        = options.aws_host       or "s3.amazonaws.com"
    options.aws_region      = options.aws_region     or "us-east-1"
    options.aws_service     = options.aws_service    or "s3"
    options.content_type    = options.content_type   or "application/x-www-form-urlencoded"
    options.request_method  = options.request_method or "GET"
    options.request_path    = options.request_path   or "/"
    options.request_body    = options.request_body   or ""
    options.iso_date        = os.date("!%Y%m%d", microtime)
    options.iso_tz          = os.date("!%Y%m%dT%H%M%SZ", microtime)
    @options = options

  -- create canonical headers
  -- header must be sorted asc
  get_canonical_header: () =>
    h = {
      "content-type:" .. @options.content_type,
      "host:" .. @options.aws_host,
      "x-amz-date:" .. @options.iso_tz
    }
    table.concat(h, "\n")

  get_signed_request_body: () =>
    params = @options.request_body
    if type(@options.request_body) == "table" then
      table.sort(params)
      params = util.query_string_encode(params)

    digest = @get_sha256_digest(params or "")
    string.lower(digest) -- hash must be in lowercase hex string

  -- get canonical request
  -- https://docs.aws.amazon.com/general/latest/gr/sigv4-create-canonical-request.html
  get_canonical_request: () =>
    param  = {
      @options.request_method,
      @options.request_path,
      "", -- canonical querystr
      @get_canonical_header(),
      "",   -- required
      "content-type;host;x-amz-date",
      @get_signed_request_body()
    }
    canonical_request = table.concat(param, "\n")
    @get_sha256_digest(canonical_request)

  -- generate sha256 from the given string
  get_sha256_digest: (s) =>
    crypto.sha256(s).hex()

  hmac: (secret, message) =>
    crypto.hmac(secret, message, crypto.sha256)

  -- get signing key
  -- https://docs.aws.amazon.com/general/latest/gr/sigv4-calculate-signature.html
  get_signing_key: () =>
    k_date    = @hmac("AWS4" .. @options.aws_secret, @options.iso_date).digest()
    k_region  = @hmac(k_date, @options.aws_region).digest()
    k_service = @hmac(k_region, @options.aws_service).digest()
    @hmac(k_service, "aws4_request").digest()

  -- get string
  get_string_to_sign: () =>
    param = { @options.iso_date, @options.aws_region, @options.aws_service, "aws4_request" }
    cred  = table.concat(param, "/")
    req   = @get_canonical_request()
    table.concat({ "AWS4-HMAC-SHA256", @options.iso_tz, cred, req }, "\n")

  -- generate signature
  get_signature: () =>
    signing_key = @get_signing_key()
    string_to_sign = @get_string_to_sign()
    @hmac(signing_key, string_to_sign).hex()

  -- get authorization string
  -- x-amz-content-sha256 required by s3
  get_authorization_header: () =>
    param = { @options.aws_key, @options.iso_date, @options.aws_region, @options.aws_service, "aws4_request" }
    header = {
      "AWS4-HMAC-SHA256 Credential=" .. table.concat(param, "/"),
      "SignedHeaders=content-type;host;x-amz-date",
      "Signature=" .. @get_signature()
    }
    table.concat(header, ", ")

  get_auth_headers: () =>
    {
      "Authorization": @get_authorization_header(),
      "x-amz-date": @get_date_header(),
      "x-amz-content-sha256": @get_content_sha256(),
      "Content-Type": @options.content_type
    }

  -- get the current timestamp in iso8601 basic format
  get_date_header: () =>
    @options.iso_tz

  get_content_sha256: () =>
    get_sha256_digest("")

{ :AwsAuth }
