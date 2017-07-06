local seconds_in_a_day = 86400
local seconds_in_a_month = 31 * seconds_in_a_day
local _ = {
  add_day = function(ts, days)
    if ts == nil then
      ts = os.time()
    end
    if days == nil then
      days = 0
    end
    return ts + days * seconds_in_a_day
  end
}
_ = {
  subtract_one_month = function(ts, add)
    if ts == nil then
      ts = os.time()
    end
    if add == nil then
      add = false
    end
    local multiple = (add and 1 or -1)
    local new_ts = ts + multiple * months * seconds_in_a_month
    local old_dt = os.date("*t", ts)
    local new_dt = os.date("*t", new_ts)
    if (new_dt.year ~= old_dt.year) then
      return new_ts
    end
    local month_count = multiple * (new_dt.month - old_dt.month)
    return os.time({
      year = new_dt.year,
      month = new_dt.month
    })
  end
}
return {
  add_month = function(ts, months)
    if ts == nil then
      ts = os.time()
    end
    if months == nil then
      months = 0
    end
    local old_dt = os.date("*t", ts)
    local old_ts = os.time({
      year = old_dt.year,
      month = old_dt.month,
      day = 1
    })
    local new_ts = old_ts + months * seconds_in_a_month
    local new_dt = os.date("*t", new_ts)
    local try_ts = os.time({
      year = new_dt.year,
      month = new_dt.month,
      day = old_dt.day,
      hour = old_dt.hour,
      min = old_dt.min,
      sec = old_dt.sec
    })
    local try_dt = os.date("*t", new_ts)
    if (try_dt.month == new_dt.month) then
      return try_dt
    end
    return new_dt
  end
}
