hmacauth = require "moonship.hmacauth"
base64_encode = (require "moonship.util").base64_encode

date_utc: (date=os.time()) -> os.date("!%a, %d, %b, %Y %H:%M:%S GMT", date)
sharedkeylite: (opts = { :account_name, :account_key, :table_name }) ->
  opts.date = opts.date or date_utc()
  opts.sig = base64_encode(opts.account_key, "#{opts.date}\n/#{opts.account_name}/#{opts.table_name}")
  opts

{ :date_utc, :sharedkeylite}
