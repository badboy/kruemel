# encoding: utf-8

require 'faraday'
require 'faraday_middleware'
require 'cgi'

class TwitterClient
  def initialize(key, token)
    @client = Faraday.new(:url => "https://api.twitter.com/") do |faraday|
      faraday.basic_auth(key, token)
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
      faraday.response :json, :content_type => /\bjson$/
    end
  end

  def token force=false
    return @access_token if @access_token && !force
    @access_token = nil

    resp = @client.post do |p|
      p.url URI.parse("/oauth2/token")
      p.headers['Content-Type'] = 'application/x-www-form-urlencoded;charset=UTF-8'
      p.body = "grant_type=client_credentials"
    end

    return nil if resp.body["token_type"] != "bearer"
    @access_token = resp.body["access_token"]
  end

  def tweet id
    a_token = token
    resp = @client.get do |p|
      p.url URI.parse("/1.1/statuses/show/#{id}.json")
      p.headers['Authorization'] = "Bearer #{a_token}"
    end

    resp.body
  end

  def timeline screen_name, count=20
    a_token = token
    resp = @client.get do |p|
      p.url URI.parse("/1.1/statuses/user_timeline.json?screen_name=#{CGI.escape screen_name}&count=#{count}")
      p.headers['Authorization'] = "Bearer #{a_token}"
    end

    resp.body
  end
end
