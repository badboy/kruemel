# encoding: utf-8

IMDB_URL = 'http://www.imdb.com/title/%s/'
API_URL = "http://www.omdbapi.com/?t=%s"

desc 'movie', '!movie', 'Get plot info about a movie (alternatives: imdb)'
hear /(?:movie|imdb)\s+(.+)/ do |message, params|
  movie = params[0]
  log "!imdb", message, params

  request(API_URL % CGI.escape(movie)) do |resp|
    json = JSON.parse(resp.body)

    if json['Error']
      post "Keine Ergebnisse für `#{movie}`. Tut mir leid."
      next
    end

    title  = json['Title']
    year   = json['Year']
    link   = IMDB_URL % json['imdbID']

    rating = json['imdbRating']
    plot   = json['Plot']
    plot ||= '-'
    plot = plot[0,200] + "..." if plot.size > 200

    post "#{title} (#{year}): #{plot} (Rating: #{rating}, #{link})"
  end
end
