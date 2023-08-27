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

profile_url = "https://github.com/#{username}?view_as=#{mode}"
# profile_url = "https://#{actor}:#{credential}@github.com/#{username}?view_as=#{mode}"
page = Nokogiri::HTML(URI.open(profile_url))
page.css("span.repo").each { |repo| puts repo.text }
