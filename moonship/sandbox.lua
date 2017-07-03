local table_unpack = table.unpack or unpack
local loadf
loadf = function(file, env)
  local chunk, err = loadfile(file)
  if chunk and env then
    setfenv(chunk, env)
  end
  return chunk, err
end
local loads
loads = function(code, name, mode, env)
  if code.byte(code, 1) == 27 then
    return nil, "can't load binary chunk"
  end
  local chunk, err = loadstring(code, name)
  if chunk and env then
    setfenv(chunk, env)
  end
  return chunk, err
end
local whitelist
whitelist = [[_VERSION assert error ipairs next pairs pcall select tonumber tostring type unpack xpcall

bit32.arshift bit32.band bit32.bnot bit32.bor bit32.btest bit32.bxor bit32.extract bit32.lrotate
bit32.lshift bit32.replace bit32.rrotate bit32.rshift

coroutine.create coroutine.isyieldable coroutine.resume coroutine.running coroutine.status
coroutine.wrap coroutine.yield

math.abs math.acos math.asin math.atan math.atan2 math.ceil math.cos math.cosh math.deg math.exp
math.floor math.fmod math.frexp math.huge math.ldexp math.log math.log10 math.max math.maxinteger
math.min math.mininteger math.mod math.modf math.pi math.pow math.rad math.random math.sin
math.sinh math.sqrt math.tan math.tanh math.tointeger math.type math.ult

os.clock os.difftime os.time

string.byte string.char string.find string.format string.gmatch string.gsub string.len string.lower
string.match string.pack string.packsize string.rep string.reverse string.sub string.unpack
string.upper

table.concat table.insert table.maxn table.pack table.remove table.sort table.unpack

utf8.char utf8.charpattern utf8.codepoint utf8.codes utf8.len utf8.offset
]]
build_env(src_env, dest_env, awhitelist)(function()
  local dest_env = dest_env or { }
  assert(getmetatable(dest_env) == nil, "env has a metatable")
  local env = { }
  for name in {
    awhitelist = gmatch("%S+")
  } do
    local t_name, field = {
      name = match("^([^%.]+)%.([^%.]+)$")
    }
    if t_name then
      local tbl = env[t_name]
      local env_t = src_env[t_name]
      if tbl == nil and env_t then
        tbl = { }
        env[t_name] = tbl
      end
      if env_t then
        local t_tbl = type(tbl)
        if t_tbl ~= "table" then
          error("field '" .. t_name .. "' already added as " .. t_tbl)
        end
        tbl[field] = env_t[field]
      end
    else
      local val = src_env[name]
      assert(type(val) ~= "table", "can't copy table reference")
      env[name] = val
    end
  end
  env._G = dest_env
  return setmetatable(dest_env, {
    __index = env
  })
end)
loadstring(code, name, env)(function()
  assert(type(code) == "string", "code must be a string")
  assert(type(env) == "table", "env is required")
  local fn, err = loads(code, name or "sandbox", "t", env)
  return nil, err
end)
loadstring_safe(code, name, env, awhitelist)(function()
  local env = build_env(_G or _ENV, env, awhitelist or whitelist)
  return loadstring(code, name, env)
end)
loadfile(file, env)(function()
  assert(type(file) == "string", "file name is required")
  assert(type(env) == "table", "env is required")
  local fn, err = loadf(file, env)
  return fn, err
end)
loadfile_safe(file, env, awhitelist)(function()
  local env = build_env(_G or _ENV, env, awhitelist or whitelist)
  return loadfile(file, env)
end)
exec(fn)(function()
  local ok, ret = pack_1(pcall(fn))
  if not (ok) then
    return ret, nil
  end
  return nil, ret[1]
end)
return {
  build_env = build_env,
  whitelist = whitelist,
  loadstring = loadstring,
  loadstring_safe = loadstring_safe,
  loadfile = loadfile,
  loadfile_safe = loadfile_safe,
  exec = exec
}
