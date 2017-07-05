-- hmac auth

util = require "moonship.util"
crypto = require "moonship.crypto"

import string_slit from util

local *
sign = (key, data="", ttl=600, ts=os.time(), algo="sha256") ->
  str = crypto.base64_encode("#{ts},#{ttl},#{data}")
  sig = crypto.hmac(key, str, algo).hex()
  "#{str}:#{sig}"

-- reverse the logic above to hmac verify
verify = (key, payload, algo="sha256") ->
  parts         = string_split(payload, ":")
  str           = crypto.base64_decode(parts[1])
  sig           = parts[2]
  ts, ttl, data = table.unpack string_split(str)

  -- validate expiration
  return { valid: false, timeout: true } if (ts < (os.time() - tonumber(ttl)))

  -- validate
  newSig = sign(key, data, ttl, ts)
  { valid: (newSig == sig) }

{ :sign, :verify }
