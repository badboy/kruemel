require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'
require 'json'

USERAGENT = "Jabbot (Ruby)"
HTTP_EXCEPTIONS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
  Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError]

# example taken from
# http://ruby-doc.org/stdlib/libdoc/net/http/rdoc/classes/Net/HTTP.html
# handles redirects correctly
def fetch(uri_str, verb=:get, limit=10)
  # You should choose better exception.
  #  Nope, I won't.
  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  uri = uri_str.kind_of?(URI) ? uri_str : URI.parse(uri_str)

  # So we can handle HTTPS aswell.
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true if uri.scheme == "https"
  response = http.start {
    uri_path = "#{uri.path.size==0?'/':uri.path}#{uri.query && '?'+uri.query}#{uri.fragment && '#'+uri.fragment}"
    case verb
    when :get
      http.request_get(uri_path, {'User-Agent' => USERAGENT})
    when :head
      http.request_head(uri_path, {'User-Agent' => USERAGENT})
    when :post
      http.request_post(uri_path, {'User-Agent' => USERAGENT})
    else
      nil
    end
  }

  case response
  when Net::HTTPSuccess     then response
  when Net::HTTPRedirection then
    loc = response['location']
    loc = "#{uri.scheme}://#{uri.host}#{loc}" if loc[0,1]=='/'
    fetch(loc, verb, limit-1)
  when nil                  then nil
  else
    response.error!
  end
end

def get_url url, params
  query =  params.map { |key, val|
    "#{CGI.escape key.to_s}=#{CGI.escape val.to_s}"
  }*"&"
  "#{url}?#{query}"
end

def request uri_str, verb=:get
  resp = fetch uri_str, verb

  if block_given?
    yield resp
  else
    resp
  end
rescue *HTTP_EXCEPTIONS => e
  post 'Ein Fehler beim Request. Tut mir leid.'
  dlog("request #{uri_str} (method: #{verb})", e.report)
  return false
end
