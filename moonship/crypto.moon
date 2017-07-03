crypto        = require "crypto"
bcrypt        = require "bcrypt"
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

bcrypt = (str, rounds) ->
  bcrypt.digest(str, rounds or 12)

md5 = (str) ->
  crypto_wrapper("md5", str)

sha1 = (str) ->
  crypto_wrapper("sha1", str)

sha256 = (str) ->
  crypto_wrapper("sha256", str)

hmac = (key, str, hasher) ->
  if hasher == md5 then
    hmac_wrapper(key, str, "md5")
  elseif hasher == sha1 then
    hmac_wrapper(key, str, "sha1")
  elseif hasher == sha256 then
    hmac_wrapper(key, str, "sha256")

{
  :base64_encode, :base64_decode, :bcrypt, :md5, :sha1, :sha256, :hmac
}
