# encoding: utf-8

def set_remember key, message
  redis.multi do
    redis.sadd 'remembers', key
    redis.set "remember:#{key}", message
  end
end

def get_remember key
  redis.get "remember:#{key}"
end

def del_remember key
  m = redis.multi do
    redis.srem 'remembers', key
    redis.del "remember:#{key}"
  end
  m.first
end

def all_remembers
  redis.sort 'remembers', :order => 'alpha'
end

def remembers_keys
  redis.smembers "remembers"
end

desc 'rem', '!rem <key> <value>'
hear /rem ([^ ]+) (.+)/ do |message, params|
  key   = params[0].downcase
  value = params[1]

  set_remember params[0].downcase, params[1]
  post "`#{key}` wurde gespeichert."
end

desc 'remlist', '!remlist'
hear /remlist( l(?:ong)?)?/ do |message, params|
  all = all_remembers
  if all.empty?
    post 'Ich hab mir garnichts merken können. :('
  else
    msg = "Folgendes habe ich mir gemerkt:\n"
    if params[0] && params[0][0,2] == ' l'
      msg << all.map{|(k,v)| "#{k}: #{v}" }*"\n"
    else
      msg << all.map{|(k,v)| k }*", "
    end
    post msg.chomp, message
  end
end

desc 'remrm', '!remrm :key'
hear /remrm ([^ ]+)/ do |message, params|
  key = params[0].downcase
  if del_remember key
    post "`#{key}` wurde entfernt."
  else
    post "`#{key}` wurde noch garnicht gespeichert."
  end
end

desc 'key', '&key'
message(/\W?&\w+\W?/) do |message, params|
  log('&:key', message, params)
  keys = message.text.scan(/\W?&(\w+)\W?/).flatten
  keys.each do |key|
    if val = get_remember(key.downcase)
      post val
    end
  end
end
