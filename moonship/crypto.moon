crypto        = require "crypto"
mybcrypt      = require "bcrypt"
crypto_hmac   = require "crypto.hmac"
mime          = require "mime"
{ :b64, :unb64 } = mime

local *

base64_encode = (...) -> (b64 ...)

base64_decode = (...) -> (unb64 ...)

crypto_wrapper = (dtype, str) ->
  {
    digest: () ->
      crypto.digest(dtype, str, true)
    ,
    hex: () ->
      crypto.digest(dtype, str, false)
  }

hmac_wrapper = (key, str, hasher) ->
  {
    digest: () ->
      crypto_hmac.digest(hasher, str, key, true)
    ,
    hex: () ->
      crypto_hmac.digest(hasher, str, key, false)
  }

bcrypt = (str, rounds=12) ->
  mybcrypt.digest(str, rounds)

bcrypt_verify = (str, digest) ->
  mybcrypt.verify( str, digest )

md5 = (str) ->
  crypto_wrapper("md5", str)

sha1 = (str) ->
  crypto_wrapper("sha1", str)

sha256 = (str) ->
  crypto_wrapper("sha256", str)

hmac = (key, str, hasher) ->
  if hasher == md5
    hmac_wrapper(key, str, "md5")
  elseif hasher == sha1
    hmac_wrapper(key, str, "sha1")
  elseif hasher == sha256
    hmac_wrapper(key, str, "sha256")

{
  :base64_encode, :base64_decode, :bcrypt, :bcrypt_verify, :md5, :sha1, :sha256, :hmac
}
