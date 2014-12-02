require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'sanitize'
require 'pry'

song_title = ARGV[0]
value = song_title.gsub(' ','+')

url = "http://www.ultimate-guitar.com/search.php?search_type=title&value=#{value}"
page = Nokogiri::HTML open(url, 'User-Agent' => 'chrome')
results_row = page.css('.tresults').first.css('tr')

matched_titles = results_row.select do |result|
  chords_or_tabs?(result) && matched_title?(result) && max_rating?(result)
end

binding.pry

def matched_title?(result)
  result.css('.song').last.attributes["class"].value == "song"
end

def max_rating?(result)
 !result.css('.r_5').empty?
end

def chords_or_tabs?(result)
  %w(chords tab).include? result.css('td strong').last.text.downcase
end

# tabs = doc.css('.tb_ct pre')[2].to_s

# File.open("#{ARGV[1]}.txt", 'w') do |file|
#   file.puts Sanitize.fragment(tabs)
# end


# match criteria
# 1. if it matches with the title name
# 2. if it's either a chord or a tab
# 3. if it's the highest rating
# 4. if it has the most number of upvotes
