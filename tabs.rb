require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sanitize'
require 'pry'

song_title = ARGV[0].gsub(' ','+')

url = "http://www.ultimate-guitar.com/search.php?search_type=title&value=#{song_title}"
page = Nokogiri::HTML open(url, 'User-Agent' => 'chrome')
results = page.css('.tresults').first.css('tr')

match = results.select do |doc|
  begin
    doc.css('.song').attributes["class"].value == "song"
  rescue NoMethodError => err 
    binding.pry
  end
end

binding.pry

# tabs = doc.css('.tb_ct pre')[2].to_s

# File.open("#{ARGV[1]}.txt", 'w') do |file|
#   file.puts Sanitize.fragment(tabs)
# end


# match criteria
# 1. if it matches with the title name
# 2. if it's either a chord or a tab
# 3. if it's the highest rating
# 4. if it has the most number of upvotes
