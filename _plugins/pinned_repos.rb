#!/usr/bin/env ruby

# get a user's pinned repos
# https://stackoverflow.com/q/43352056/4058484

require 'rubygems'
require 'nokogiri'
require 'open-uri'

# if ARGV.length != 1
#  STDERR.puts "usage: /maps/pinned_repos.rb <username>"
#  exit 1
# end

actor = ARGV[0]
credential = ARGV[1]
username = ARGV[2]
mode = ARGV[3]

# open("http://...", :http_basic_authentication=>[user, password])
# profile_url = "https://github.com/#{username}?view_as=#{mode}"

# uri = URI.parse("https://github.com/#{username}")

# params = { :view_as => "#{mode}" }
# uri.query = URI.encode_www_form( params )

profile_url = "https://github.com/#{username}"
page = Nokogiri::HTML(URI.open(profile_url, "Authorization" => "Bearer #{credential}"))
page.css("span.repo").each { |repo| puts repo.text }
