# encoding: utf-8

hear 'reload' do
  post 'Reloading plugins ...'
  reset_handlers
  reload_plugins
  post 'Reloading done.'
end

hear(/help(?:\s(.+))?/, :prefix => /(?:#{bot.nick}[,:]? |!|>)/) do |message, params|
  log('!help', message, params)
  if params[0]
    command = params[0].downcase
    name, phrase, func = $descriptions.find{|(name, p, f)|
      command == name
    }
    if phrase
      msg = "#{phrase}"
      msg << ': ' << func if func
    else
      msg = "'#{command}' gibt es nicht."
    end
  else
    msg = "Folgende Kommandos stehen zur Verfügung:\n"
    descs = $descriptions.map{|(name, phrase, func)|
      name
    }.sort
    msg << descs*', '
  end

  if message.text[0] == '>'
    post msg.chomp => message.user
  else
    post msg.chomp, message
  end
end
