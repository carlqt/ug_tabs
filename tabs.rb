require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sanitize'

url = ARGV[0]
filename = ARGV[1]

doc = Nokogiri::HTML open(url)
tabs = doc.css('.tb_ct pre')[2].to_s

File.open("#{ARGV[1]}.txt", 'w') do |file|
  file.puts Sanitize.fragment(tabs)
end
