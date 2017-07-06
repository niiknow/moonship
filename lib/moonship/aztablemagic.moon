-- magical help function to add
-- 1. multitenancy
-- 2. timeseries table manipulation

azauth = require "moonship.azauth"
aztable = require "moonship.aztable"
mydate = require "moonship.date"
string_gsub = string.gsub

env_id = (env="dev") ->
  switch type env
    when "dev"
      return 79
    when "tst"
      return 77
    when "uat"
      return 75
    when "stg"
      return 73
    when "prd"
      return 71

  -- default to dev
  return 79

-- generate multitenant opts
opts_name = (opts={ :account_name, :account_key, :table_name, :tenant, :env, :pk, :rk, :prefix }) ->
  opts.pk = opts.pk or "1default"
  opts.tenant = opts.tenant or "a"
  opts.table = opts.table_name
  opts.env_id = env_id(env)
  opts.prefix = "#{opts.tenant}#{opts.env_id}"
  opts.table_name = "#{opts.prefix}#{opts.table}"

generate_opts = (opts={ :account_name, :account_key, :table_name, :tenant, :env, :pk, :rk, :prefix }, format="%Y%m%d", ts=os.time()) ->
  newopts = util.table_clone(opts)
  newopts.mt_table = newopts.table_name
  -- trim ending number and replace with dt
  newopts.table_name = string_gsub(newopts.mt_table, "\d+$", "") .. os.date(format, ts)
  newopts

-- generate array of daily opts
opts_daily = (opts={ :account_name, :account_key, :table_name, :tenant, :env, :pk, :rk, :prefix }, days=1, ts=os.time()) ->
  rst = {}
  multiplier = days and 1 or -1
  new_ts = ts
  for i = 1, days
    rst[#rst + 1] = generate_opts(opts, "%Y%m%d", new_ts)
    new_ts = mydate.add_day(new_ts, days)

  rst

-- generate array of monthly opts
opts_monthly = (opts={ :account_name, :account_key, :table_name, :tenant, :env, :pk, :rk, :prefix }, months=1, ts=os.time()) ->
  rst = {}
  multiplier = days and 1 or -1
  new_ts = ts
  for i = 1, days
    rst[#rst + 1] = generate_opts(opts, "%Y%m", new_ts)
    new_ts = mydate.add_month(new_ts, months)

  rst

-- generate array of yearly opts
opts_yearly = (opts={ :account_name, :account_key, :table_name, :tenant, :env, :pk, :rk, :prefix }, years=1, ts=os.time()) ->
  rst = {}
  multiplier = days and 1 or -1
  new_ts = ts
  for i = 1, days
    rst[#rst + 1] = generate_opts(opts, "%Y%m%d", new_ts)
    new_ts = mydate.add_year(new_ts, years)

  rst

{ :opts_name, :opts_daily, :opts_monthly, :opts_yearly }
