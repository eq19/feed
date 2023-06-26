#!/usr/bin/env ruby
# get a user's pinned repos
require 'rubygems'
require 'nokogiri'
require 'open-uri'

#if ARGV.length != 1
#  STDERR.puts "usage: get_user_pinned_repos <username>"
#  exit 1
#end

#username = ARGV.first
profile_url = "https://github.com/FeedMapping"
page = Nokogiri::HTML(URI.open(profile_url))
page.css("span.repo").each { |repo| puts repo.text }
