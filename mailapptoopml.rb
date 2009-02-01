#!/usr/bin/ruby

# Welcome to the MailAppToOPML Script
# What it does: Simply converts the RSS/Atom Newsfeeds that you have subscribed to using Mail.app
#                 and then turns it into OPML, so that it can be used in other news readers
# @author: Daniel Lewis
# Personal Email of Author: danieljohnlewis [-a-t-] gmail [-d-o-t-] com
# Authors Blog: http://vanirsystems.com/danielsblog
# This software works with Mail.app on Mac OS X. It is built using the Ruby Programming Language.
# It is licensed under LGPL.

require 'uri'
require 'find'
require 'date'

def opmlline(infoplist, text)
  output = ""
  infopliststr = infoplist.read
  infopliststr.scan(URI.regexp) do |*matches|
    if $& != "http://www.apple.com/DTDs/PropertyList-1.0.dtd"
      output << "<outline title=\"#{text}\" text=\"#{text}\" type=\"rss\" xmlUrl=\"#{$&}\" />"
    end
  end
  return output
end

def writeopml(opmllines)
  File.open("rssfeeds.opml",  "a") do |f|
    f.puts "<?xml version=\"1.0\" encoding=\"utf-8\" ?><opml version=\"1.1\"> <head>   <title>RSS Feeds</title>   <dateCreated>#{Date.new.to_s}</dateCreated></head><body>"
    opmllines.each_pair do |folders, opmldata|
      folders.scan(/(.*?)\//).each do |folder|
        f.puts %Q[<outline title="#{folder}" text="#{folder}">]
      end

      f.puts opmldata

      f.puts %Q[</outline>\n\n]*folders.count("/")
    end
    f.puts "</body></opml>"
    return Dir.pwd + "/" + f.path
  end
end

namere = /RSS\/(.*?\/)+(.*?)\.rssmbox\/Info.plist/
path = File.expand_path("~/Library/Mail/RSS/")
opmllines = Hash.new
Find.find(path) do |p1| 
  if m=p1.match(namere)
    folders = m[1].freeze
    text    = m[2]
    opmllines[folders] ||= ""
    lines = ""
    File.open(p1.to_s, "r") do |p1file|
      opmllines[folders] << opmlline(p1file, text)
    end
  end
end

opmlfilepath = writeopml(opmllines)
puts "The location of your OPML file is: #{opmlfilepath}"
