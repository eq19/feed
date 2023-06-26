#!/bin/ruby
# get a user's pinned repos
require 'rubygems'
require 'nokogiri'
require 'open-uri'

profile_url = "https://github.com/eq19"
page = Nokogiri::HTML(open(profile_url))
page.css("span.repo").each { |repo| puts repo.text }
