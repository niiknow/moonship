local util = require("moonship.util")
local crypto = require("moonship.crypto")
local string_slit, base64_encode, base64_decode
string_slit, base64_encode, base64_decode = util.string_slit, util.base64_encode, util.base64_decode
local unpack
unpack = table.unpack
local sign, verify, sign_custom, verify_custom
sign = function(key, data, algo)
  if algo == nil then
    algo = "sha256"
  end
  return crypto.hmac(key, str, algo).digest()
end
verify = function(key, data, algo)
  if algo == nil then
    algo = "sha256"
  end
  return data == sign(key, data, algo)
end
sign_custom = function(key, data, ttl, ts, algo)
  if data == nil then
    data = ""
  end
  if ttl == nil then
    ttl = 600
  end
  if ts == nil then
    ts = os.time()
  end
  if algo == nil then
    algo = "sha256"
  end
  return base64_encode(tostring(ts) .. ":" .. tostring(ttl) .. ":" .. tostring(data) .. ":" .. sign(tostring(ts) .. ":" .. tostring(ttl) .. ":" .. tostring(data)))
end
verify_custom = function(key, payload, algo)
  if algo == nil then
    algo = "sha256"
  end
  local ts, ttl, data, sig = unpack(string_split(base64_decode(payload), ":"))
  if (ts < (os.time() - tonumber(str[2]))) then
    return {
      valid = false,
      timeout = true
    }
  end
  return {
    valid = (sig == sign(key, data, ttl, ts))
  }
end
return {
  sign = sign,
  verify = verify
}
