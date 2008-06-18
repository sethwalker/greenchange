#! /usr/local/bin/ruby

current = (File.expand_path(File.dirname(__FILE__)) )
puts current
puts Dir.entries(current).size
Dir.entries(current).each do |filename|
  next unless filename =~ / copy/
  matches = filename.match( /^(.+) copy(.+)/ )
  puts matches[1] + matches[2]
  puts "mv #{filename.gsub(' ', '\ ')} #{matches[1] + matches[2]}"
  %x( mv #{filename.gsub(' ', '\ ')} #{matches[1] + matches[2]} )
end
