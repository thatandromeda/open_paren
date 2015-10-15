#!/usr/bin/env ruby

# Lets me add title and description to my mp3 files, so that dropcaster
# can munge them into XML.

require "mp3info"

dir = Dir.pwd + '/'

Dir.entries(dir).each do |file|
    next if file !~ /.mp3$/ # skip files not ending with .mp3
    Mp3Info.open(dir + file) do |mp3|
        puts file
        unless mp3.tag.title?
            puts "What should the title of this episode be?"
            mp3.tag.title = gets.rstrip
        end

        unless mp3.tag.comments?
            puts "What should the description of this episode be?"
            mp3.tag.comments = gets.rstrip
        end
    end
end
