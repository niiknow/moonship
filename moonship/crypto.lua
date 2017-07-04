local crypto = require("crypto")
local mybcrypt = require("bcrypt")
local crypto_hmac = require("crypto.hmac")
local mime = require("mime")
local b64, unb64
b64, unb64 = mime.b64, mime.unb64
local base64_encode, base64_decode, crypto_wrapper, hmac_wrapper, bcrypt, bcrypt_verify, md5, sha1, sha256, hmac
base64_encode = function(...)
  return (b64(...))
end
base64_decode = function(...)
  return (unb64(...))
end
crypto_wrapper = function(dtype, str)
  return {
    digest = function()
      return crypto.digest(dtype, str, true)
    end,
    hex = function()
      return crypto.digest(dtype, str, false)
    end
  }
end
hmac_wrapper = function(key, str, hasher)
  return {
    digest = function()
      return crypto_hmac.digest(hasher, str, key, true)
    end,
    hex = function()
      return crypto_hmac.digest(hasher, str, key, false)
    end
  }
end
bcrypt = function(str, rounds)
  if rounds == nil then
    rounds = 12
  end
  return mybcrypt.digest(str, rounds)
end
bcrypt_verify = function(str, digest)
  return mybcrypt.verify(str, digest)
end
md5 = function(str)
  return crypto_wrapper("md5", str)
end
sha1 = function(str)
  return crypto_wrapper("sha1", str)
end
sha256 = function(str)
  return crypto_wrapper("sha256", str)
end
hmac = function(key, str, hasher)
  if hasher == md5 then
    return hmac_wrapper(key, str, "md5")
  elseif hasher == sha1 then
    return hmac_wrapper(key, str, "sha1")
  elseif hasher == sha256 then
    return hmac_wrapper(key, str, "sha256")
  end
end
return {
  base64_encode = base64_encode,
  base64_decode = base64_decode,
  bcrypt = bcrypt,
  bcrypt_verify = bcrypt_verify,
  md5 = md5,
  sha1 = sha1,
  sha256 = sha256,
  hmac = hmac
}
