local util = require("moonship.util")
local crypto = require("moonship.crypto")
local string_slit
string_slit = util.string_slit
local sign, verify
sign = function(key, data, ttl, ts, algo)
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
  local str = crypto.base64_encode(tostring(ts) .. "," .. tostring(ttl) .. "," .. tostring(data))
  local sig = crypto.hmac(key, str, algo).hex()
  return tostring(str) .. ":" .. tostring(sig)
end
verify = function(key, payload, algo)
  if algo == nil then
    algo = "sha256"
  end
  local parts = string_split(payload, ":")
  local str = crypto.base64_decode(parts[1])
  local sig = parts[2]
  local ts, ttl, data = table.unpack(string_split(str))
  if (ts < (os.time() - tonumber(ttl))) then
    return {
      valid = false,
      timeout = true
    }
  end
  local newSig = sign(key, data, ttl, ts)
  return {
    valid = (newSig == sig)
  }
end
return {
  sign = sign,
  verify = verify
}
