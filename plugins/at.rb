# encoding: utf-8
require 'digest/sha1'

$timer_table = {}

def new_timer secs, msg, message
  timestamp = Time.now + secs
  sha = Digest::SHA1.hexdigest("#{timestamp}-#{msg}")[0,3]

  if $timer_table[sha]
    post 'Genau die Erinnerung hab ich doch schon. Such dir was anderes aus.'
  else
    if secs > 0 && secs < 36000
      #t = EM.add_timer(secs) { post "#{user}: #{msg}", message }
      $timer_table[sha] = EM::Timer.new(secs) {
        post msg, message
        $timer_table.delete sha
      }
      post "Ich werde dich nachher dran erinnern. (##{sha})", message
    else
      if secs <= 0
        post 'Du musst mir schon kurz Zeit lassen.', message
      else
        post 'Na also ehrlich: das kannst du dir auch in den Kalender schreiben.', message
      end
    end
  end
end

desc 'at', '!at <time> <msg>', 'Erinnerung zu einer bestimmten Uhrzeit (Format: HH:MM)'
hear /at (\d{1,2}[:.]\d{1,2})(?:\s+(.+))?/ do |message, params|
  time = params[0].gsub(/\./, ':')
  parsed = Time.parse(time)
  now = Time.now
  secs = (parsed - Time.now).round
  msg = params[1] || 'ALARM! ALARM!'
  user = message.user

  new_timer secs, "#{user}: #{msg}", message
end

desc 'in', '!in <time> <msg>', 'Erinnerung nach einer Zeitspanne (Suffix: m=Minuten, s=Sekunden, h=Stunden, Default: m)'
hear /in (\d+)(min|s|m|h)?(?:\s(.+))?/ do |message, params|
  time = params[0].to_i
  suffix = params[1] || 'm'
  msg = params[2] || 'ALARM! ALARM!'

  secs = case suffix
         when 'm'   then time * 60
         when 'min' then time * 60
         when 'h'   then time * 60 * 60
         else time
         end

  user = message.user
  new_timer secs, "#{user}: #{msg}", message
end

desc 'atc', '!atc <id>', 'Erinnerung löschen (ID siehe vorige Aussgabe).'
hear /(?:atc|inc) (.+)?/ do |message, params|
  id = params[0].sub(/^#/, '')

  if !$timer_table[id].nil?
    $timer_table[id].cancel
    $timer_table.delete(id)
    post 'Also keine Erinnerung. Ok.', message
  else
    post 'Keine Erinnerung mit der ID. Hast du was vergessen?', message
  end
end
