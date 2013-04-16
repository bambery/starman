require File.expand_path('config/boot', File.dirname(__FILE__))

log = File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)


run Starman
