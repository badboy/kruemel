# encoding: utf-8

message(/^#{bot.nick}(\?|[,:] *)$/) do |message, params|
  post "Anwesend. Gibt's was zu tun?"
end

desc 'info', '!info'
hear 'info' do |message, params|
  post "Hier läuft Jabbot v#{Jabbot::VERSION} auf #{`hostname -f`.chomp} (Ruby #{RUBY_VERSION}, #{`uname -sr`.chomp})", message
end

hear 'ping' do |message, params|
  post 'pong'
end

hear /(?:say|echo) (.+)/ do |message, params|
  post params.first
end

desc 'time', '!time', 'Say the time.'
hear 'time' do |message, params|
  post "Server time is: #{Time.new}"
end

# exit bot, gets restarted by monit
hear 'die', :query => false do |message, params|
  post '…und tschüss.'
  close
end
