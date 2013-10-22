def log(com, msg, params=nil)
  if params
    $stdout.puts "#{msg.time} | #{com} | #{params.inspect} | <#{msg.user}> #{msg.text}"
  else
    $stdout.puts "#{msg.time} | #{com} | <#{msg.user}> #{msg.text}"
  end
end

def dlog(com, msg)
  $stdout.puts "#{Time.now} | #{com} | #{msg}"
end

# Store function descriptions for use with !help
$descriptions = []
def desc(name, phrase, func=nil)
  $descriptions << [name, phrase, func]
end

$plugins = []
$plugin_load_finished = false
def plugin(name)
  $plugins << name unless $plugin_load_finished
  file = File.join(HERE, "plugins", "#{name}.rb")
  load file
end

def plugins_done
  $plugin_load_finished = true
end

def reset_handlers
  bot.instance_eval {
    @handlers = {
      :message => [],
      :private => [],
      :join    => [],
      :subject => [],
      :leave   => []
    }
  }
end

def hear(regex, opt={}, &blk)
  prefix = opt.delete(:prefix) || /(?:#{bot.nick}[,:]? |!)/
  exact = opt.delete(:exact)
  opt = {:query => true}.merge(opt)

  regex = /#{prefix}#{regex}/
  if exact
    message({:exact => regex}, opt, &blk)
  else
    message(/\A#{regex}\s*\Z/, opt, &blk)
  end
end

def silence_warnings
  old_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = old_verbose
end

def reload_plugins
  silence_warnings do
    $descriptions = []
    $plugins.each do |plug|
      plugin plug
    end
  end
end
