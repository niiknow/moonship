crypto        = require "crypto"
crypto_hmac   = require "crypto.hmac"
mybcrypt      = require "bcrypt"
mime          = require "mime"

{ :b64, :unb64 } = mime

local *

base64_encode = (...) -> (b64 ...)

base64_decode = (...) -> (unb64 ...)

crypto_wrapper = (dtype, str) ->
  {
    digest: () -> crypto.digest(dtype, str, true)
    hex: () -> crypto.digest(dtype, str, false)
  }

hmac_wrapper = (key, str, algo) ->
  {
    digest: () -> crypto_hmac.digest(algo, str, key, true)
    hex: () -> crypto_hmac.digest(algo, str, key, false)
  }

bcrypt = (str, rounds=12) -> mybcrypt.digest(str, rounds)
bcrypt_verify = (str, digest) -> mybcrypt.verify( str, digest )
md5 = (str) -> crypto_wrapper("md5", str)
sha1 = (str) -> crypto_wrapper("sha1", str)
sha256 = (str) -> crypto_wrapper("sha256", str)
hmac = (key, str, algo) ->
  if algo == md5
    hmac_wrapper(key, str, "md5")
  elseif algo == sha1
    hmac_wrapper(key, str, "sha1")
  elseif algo == sha256
    hmac_wrapper(key, str, "sha256")

{ :base64_encode, :base64_decode, :bcrypt, :bcrypt_verify, :md5, :sha1, :sha256, :hmac }
