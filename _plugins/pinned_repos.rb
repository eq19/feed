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

username = ARGV.first
profile_url = "https://github.com/#{username}"
page = Nokogiri::HTML(URI.open(profile_url))
page.css("span.repo").each { |repo| puts repo.text }
