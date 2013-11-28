# encoding: utf-8

require 'nokogiri'

DEFAULT_ENCODINGS      = %w[ utf-8 utf8 UTF8 UTF-8 ]
BLOCKED_HOSTS          = %w[ localhost 127.0.0.1 ]
TITLE_MAX_LENGTH       = 100
GET_ONLY = %w[ news.ycombinator.com
               www.amazon.de www.amazon.com amazon.de amazon.com
             ]

# 0.5 MB max.
LINK_MAX_SIZE = 512 * 1024

def correctly_encode str, to_enc=DEFAULT_ENCODINGS.first
  str.encode(to_enc, {
    invalid: :replace,
    undef:   :replace,
    replace: '?'
  })
end

def choose_encoding doc
  http_equiv = doc.css('meta[http-equiv=content-type]').first
  if http_equiv && content = http_equiv.attributes['content']
    send_encoding = content.to_s.gsub(/^.+charset=/, '')
  end

  # handle HTML5 encoding definition
  if !http_equiv && http_equiv = doc.css('meta[charset]').first
    send_encoding = http_equiv.attributes['charset'].to_s
  end

  send_encoding
end

def extract_title doc, send_encoding
  title = doc.css("title")
  return if !title || title.empty?

  title = title[0].content

  if send_encoding && !DEFAULT_ENCODINGS.include?(send_encoding)
    title.force_encoding(send_encoding)
    title = correctly_encode(title)
  end

  title = title.strip.gsub(/\r/, '').gsub(/\n/, ' ').gsub(/\s+/, ' ')
  title = title[0, TITLE_MAX_LENGTH] + '...' if title.length > TITLE_MAX_LENGTH

  title
end

def get_request uri, send_encoding=nil
  request(uri) do |req|
    doc = Nokogiri::HTML req.body

    next unless doc

    if !send_encoding
      if req.header['content-type'] =~ /^.+charset=(.+)/i
        send_encoding = $1
      else
        send_encoding = choose_encoding doc
      end
    end

    title = extract_title doc, send_encoding
    if title
      post "Titel: #{title} (at #{uri.host} )"
    else
      post "Titel: <empty> (at #{uri.host} )"
    end
  end
end

def head_request uri
  request(uri, :head) do |req|
    size = req.header['content-length'].to_i

    next if size > LINK_MAX_SIZE
    next if req.header['content-type'] !~ /text/i

    # HTTP Content-Type charset is preferred
    send_encoding = $1 if req.header['content-type'] =~ /^.+charset=(.+)/i

    get_request uri, send_encoding
  end
end

message(/(https?:\/\/\S+)/) do |message, params|
  begin
    next if message.text =~ /\A\s*!\w+/

    log("link", message)

    uri = params[0].sub(/>$/, '')
    uri = URI.parse(uri)

    next if BLOCKED_HOSTS.include?(uri.host)

    case uri.to_s
    when TWITTER_REGEX
      msg = twitter([uri.to_s])
      post msg ? msg : TWITTER_FAIL
    else
      # Only get the HTTP headers.

      if GET_ONLY.include?(uri.host)
        get_request(uri)
      else
        # Only get the HTTP headers.
        head_request(uri)
      end
    end

  rescue SocketError => e
    if e.message == "getaddrinfo: No address associated with hostname"
      post 'Die angegebene Seite existiert nicht.'
    else
      $stderr.puts e.report
      $stderr.puts uri.inspect
      $stderr.puts message.inspect
    end
  rescue Exception => e
    $stderr.puts e.report
    $stderr.puts uri.inspect
    $stderr.puts message.inspect
  end
end
