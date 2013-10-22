# encoding: utf-8

TWITTER_CONSUMER_KEY    = ENV['TWITTER_CONSUMER_KEY']
TWITTER_CONSUMER_SECRET = ENV['TWITTER_CONSUMER_SECRET']
TWITTER_BASE   = 'http://api.twitter.com/1/statuses/show/'
TWITTER_FORMAT = 'json'
TWITTER_REGEX  = %r{https?://twitter.com/.+?/status(?:es)?/(\d+)}
TWITTER_FAIL   = 'Twitter hat nicht sinnvolles geantwortet. Hey. Guck nicht so! DIE sind schuld.'

CONV_LEVEL_MAX = 10

def twitter_id id
  id.gsub!(/\s/, '')
  if id =~ TWITTER_REGEX
    $1
  elsif !(id =~ /\A\d+\z/)
    nil
  else
    id
  end
end

def twitter_client
  TwitterClient.new(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET)
end

def twitter(params)
  tw_id = twitter_id params[0]

  return 'Eine Twitter-ID besteht nur aus Zahlen, also gib mir auch so eine.' unless tw_id

  t = twitter_client
  json = t.tweet tw_id

  if json['errors']
    error = json['errors'].first['message']
    return error
  end

  time = Time.parse(json['created_at']).strftime('%d.%m.%Y %H:%M')
  user = json['user']['screen_name']
  mess = CGI.unescapeHTML(json['text'])

  "[#{time}] @#{user}: #{mess}"
end

def tw_client tw_id
  t = twitter_client
  json = t.tweet tw_id
  source = json['source']
  if source[0,2] == "<a"
    d = Nokogiri::HTML source
    a = d.search('a').first
    href = a['href']
    "Tweet via #{d.content} (#{href})"
  else
    "Tweet via #{source}"
  end
end

def conversation tw_id
  level = 0
  conv = []
  t = twitter_client
  while tw_id && level < CONV_LEVEL_MAX
    json = t.tweet tw_id
    if json['errors']
      error = json['errors'].first['message']
      return error
    end

    time = Time.parse(json['created_at']).strftime('%d.%m.%Y %H:%M')
    user = json['user']['screen_name']
    mess = CGI.unescapeHTML(json['text'])

    conv.unshift "[#{time}] @#{user}: #{mess}"

    tw_id = json['in_reply_to_status_id_str']

    level += 1
  end

  conv
end

desc 'tw', '!tw <id>'
hear 'tw (.+)' do |message, params|
  begin
    log('!tw', message)
    msg = twitter(params)
    post msg ? msg : TWITTER_FAIL
  rescue Exception => e
    puts e.report
    post 'Sorry, irgendwas ist schief gelaufen...'
  end
end

desc 'conv', '!conv <id>'
hear 'conv (.+)' do |message, params|
  log '!conv', message
  tw_id = twitter_id params[0]

  if tw_id
    conv = conversation(tw_id)
    post conv*"\n" unless conv.empty?
  else
    post 'Eine Twitter-ID besteht nur aus Zahlen, also gib mir auch so eine.'
  end
end

desc 'twclient', '!twclient <id>'
hear 'twclient (.+)' do |message, params|
  log '!twclient', message
  tw_id = twitter_id params[0]

  if !tw_id
    post 'Eine Twitter-ID besteht nur aus Zahlen, also gib mir auch so eine.'
  else
    conv = tw_client(tw_id)
    post conv ? conv : "Hm, Fehler!"
  end
end
