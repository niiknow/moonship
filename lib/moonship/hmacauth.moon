-- hmac auth

util = require "moonship.util"
crypto = require "moonship.crypto"

import string_slit, base64_encode, base64_decode from util
import unpack from table

local *
sign = (key, data, algo="sha256") -> crypto.hmac(key, str, algo).digest()
verify = (key, data, algo="sha256") -> data == sign(key, data, algo)
sign_custom = (key, data="", ttl=600, ts=os.time(), algo="sha256") -> base64_encode("#{ts}:#{ttl}:#{data}:" .. sign("#{ts}:#{ttl}:#{data}"))

-- reverse the logic above to hmac verify
verify_custom = (key, payload, algo="sha256") ->
  ts, ttl, data, sig = unpack string_split(base64_decode(payload), ":")
  -- validate expiration
  return { valid: false, timeout: true } if (ts < (os.time() - tonumber(str[2])))

  -- validate
  { valid: (sig == sign(key, data, ttl, ts)) }

{ :sign, :verify }
