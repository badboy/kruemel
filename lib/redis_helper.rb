def connect_redis
  $raw_redis ||= Redis.new
  $redis ||= Redis::Namespace.new :kruemel, :redis => $raw_redis
end

def redis
  connect_redis
  $redis
end

def raw_redis
  connect_redis
  $raw_redis
end
