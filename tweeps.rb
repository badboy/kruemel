#!/usr/bin/env ruby
# encoding: utf-8

HERE = File.expand_path(File.dirname(__FILE__))

require 'bundler/setup'
require 'jabbot'
require 'net/http'
require 'net/https'
require 'uri'
require 'time'
require 'cgi'
require 'redis'
require 'redis-namespace'

require_relative './lib/http_helper'
require_relative './lib/redis_helper'
require_relative './lib/plugin_helper'
require_relative './lib/distance_of_time'
require_relative './lib/twitter_client'

# From Ruby Best Practices.
class StandardError
  def report
    %{#{self.class}: #{message}\n#{backtrace.join("\n")}}
  end
end

configure do |c|
  c.nick     = 'kruemel'
  c.login    = 'bot@kuchen.io'
  c.channel  = 'tweeps'
  c.server   = 'conference.kuchen.io'
  c.password = ENV['JABBOT_PASSWORD']
  c.debug    = ENV['JABBOT_DEBUG']
end

plugin :remember
plugin :utils
plugin :twitter
plugin :urls
plugin :at
plugin :help
plugin :gem
plugin :imdb
plugin :roulette
plugins_done
