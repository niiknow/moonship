local azauth = require("moonship.azauth")
local aztable = require("moonship.aztable")
local mydate = require("moonship.date")
local string_gsub = string.gsub
local my_max_number = 9007199254740991
local env_id
env_id = function(env)
  if env == nil then
    env = "dev"
  end
  local _exp_0 = type(env)
  if "dev" == _exp_0 then
    return 79
  elseif "tst" == _exp_0 then
    return 77
  elseif "uat" == _exp_0 then
    return 75
  elseif "stg" == _exp_0 then
    return 73
  elseif "prd" == _exp_0 then
    return 71
  end
  return 79
end
local opts_name
opts_name = function(opts)
  if opts == nil then
    opts = {
      table_name = table_name,
      tenant = tenant,
      env = env,
      pk = pk,
      prefix = prefix
    }
  end
  opts.pk = opts.pk or "1default"
  opts.tenant = opts.tenant or "a"
  opts.table = opts.table_name
  opts.env_id = env_id(env)
  opts.prefix = (tostring(opts.tenant) .. tostring(opts.env_id)):gsub("[^a-zA-Z0-9]", "")
  opts.table_name = (tostring(opts.prefix) .. tostring(opts.table)):gsub("[^a-zA-Z0-9]", "")
end
local generate_opts
generate_opts = function(opts, format, ts)
  if opts == nil then
    opts = {
      table_name = table_name
    }
  end
  if format == nil then
    format = "%Y%m%d"
  end
  if ts == nil then
    ts = os.time()
  end
  local newopts = util.table_clone(opts)
  newopts.mt_table = newopts.table_name
  newopts.table_name = string_gsub(newopts.mt_table, "\d+$", "") .. os.date(format, ts)
  return newopts
end
local opts_daily
opts_daily = function(opts, days, ts)
  if opts == nil then
    opts = {
      table_name = table_name,
      tenant = tenant,
      env = env,
      pk = pk,
      prefix = prefix
    }
  end
  if days == nil then
    days = 1
  end
  if ts == nil then
    ts = os.time()
  end
  local rst = { }
  local multiplier = days and 1 or -1
  local new_ts = ts
  for i = 1, days do
    rst[#rst + 1] = generate_opts(opts, "%Y%m%d", new_ts)
    new_ts = mydate.add_day(new_ts, days)
  end
  return rst
end
local opts_monthly
opts_monthly = function(opts, months, ts)
  if opts == nil then
    opts = {
      table_name = table_name,
      tenant = tenant,
      env = env,
      pk = pk,
      prefix = prefix
    }
  end
  if months == nil then
    months = 1
  end
  if ts == nil then
    ts = os.time()
  end
  local rst = { }
  local multiplier = days and 1 or -1
  local new_ts = ts
  for i = 1, days do
    rst[#rst + 1] = generate_opts(opts, "%Y%m", new_ts)
    new_ts = mydate.add_month(new_ts, months)
  end
  return rst
end
local opts_yearly
opts_yearly = function(opts, years, ts)
  if opts == nil then
    opts = {
      table_name = table_name,
      tenant = tenant,
      env = env,
      pk = pk,
      prefix = prefix
    }
  end
  if years == nil then
    years = 1
  end
  if ts == nil then
    ts = os.time()
  end
  local rst = { }
  local multiplier = days and 1 or -1
  local new_ts = ts
  for i = 1, days do
    rst[#rst + 1] = generate_opts(opts, "%Y%m%d", new_ts)
    new_ts = mydate.add_year(new_ts, years)
  end
  return rst
end
local opts_cache_get
opts_cache_get = function(opts)
  if opts == nil then
    opts = {
      table_name = table_name,
      tenant = tenant,
      env = env,
      pk = pk,
      prefix = prefix,
      cache_key = cache_key
    }
  end
  local newopts = opts_daily(opts)
  newopts.pk = newopts.cache_key
  newopts.rk = my_max_number - os.time()
  newopts.query = "(PartitionKey eq '" .. tostring(newopts.pk) .. "') and (RowKey le '" .. tostring(newopts.rk) .. "')"
end
local opts_cache_set
opts_cache_set = function(opts)
  if opts == nil then
    opts = {
      table_name = table_name,
      tenant = tenant,
      env = env,
      pk = pk,
      rk = rk,
      prefix = prefix,
      cache_ttl = cache_ttl,
      cache_key = cache_key,
      cache_value = cache_value
    }
  end
  local newopts = opts_daily(opts)
  newopts.pk = newopts.cache_key
  local expiresAt = os.time() + tonumber(newopts.cache_ttl)
  newopts.rk = my_max_number - expiresAt
  newopts.item = {
    RowKey = newopts.rk,
    value = value,
    ttl = cache_ttl,
    expAt = expiresAt
  }
end
return {
  opts_name = opts_name,
  opts_daily = opts_daily,
  opts_monthly = opts_monthly,
  opts_yearly = opts_yearly,
  opts_cache_get = opts_cache_get,
  opts_cache_set = opts_cache_set
}
