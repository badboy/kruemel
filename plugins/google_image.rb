# encoding: utf-8

# Idea:
#   https://github.com/github/hubot/blob/master/src/scripts/google-images.coffee

IMAGE_SEARCH_URL='http://ajax.googleapis.com/ajax/services/search/images'

def image_me query, animated=false, &cb
  q = {
    v:     '1.0',
    rsz:   '8',
    q:     query,
    safe:  'active'
  }

  q[:imgtype] = 'animated' if animated

  request(get_url(IMAGE_SEARCH_URL, q)) do |resp|
    images = JSON.parse resp.body
    images = images['responseData']
    if images
      images = images['results']
      image  = images.sample["unescapedUrl"]
    else
      image = "No image"
    end

    cb.call(image)
  end
end

hear /(?:image|img)(?: me)? (.+)/ do |message, params|
  log "!image", message, params
  query = params[0]

  image_me(query, false) do |img|
    post img
  end
end

hear /(?:animate|gif)(?: me)? (.+)/ do |message, params|
  log "!anmiate", message, params
  query = params[0]

  image_me(query, true) do |img|
    post img
  end
end
