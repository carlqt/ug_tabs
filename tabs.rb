require 'pry'
def load_missing_gem(name, version=nil)
  # needed if your ruby version is less than 1.9

  begin
    gem name, version
  rescue LoadError
    version = "--version '#{version}'" unless version.nil?
    system("gem install #{name} #{version}")
    Gem.clear_paths
    retry
  end

  # require name
end

begin
  require 'rubygems'
  require 'nokogiri'
  require 'open-uri'
  require 'sanitize'

  def matched_title?(result, title)
    return false if result.css('.song').empty?
    result.css('.song').last.attributes["class"].value == "song" && result.css('.song').last.text.downcase.match(title)
  end

  def max_rating?(result)
    # return false if result.css('.song').empty
   !result.css('.r_5').empty?
  end

  def chords_or_tabs?(result)
    return false if result.css('td strong').empty?
    %w(chords tab).include? result.css('td strong').last.text.downcase
  end

  song_title = ARGV[0]
  value = song_title.gsub(' ','+')
  rating_hash = { "r_1" => 1, "r_2" => 2, "r_3" => 3, "r_4" => 4, "r_5" => 5 }

  url = "http://www.ultimate-guitar.com/search.php?search_type=title&value=#{value}"
  page = Nokogiri::HTML open(url, 'User-Agent' => 'chrome')
  results_row = page.css('.tresults').first.css('tr')

  matched_titles = results_row.select do |result|
    chords_or_tabs?(result) && matched_title?(result, song_title)
  end

  new_page = Nokogiri::HTML matched_titles.columnize

  # song_match = matched_titles.select do |match|

  # end

  highest_rated = if new_page.css('.r_5')
    new_page.css('.r_5')
  else
    if new_page.css('.r_4')
      new_page.css('.r_4')
    else
      if new_page.css('.r_3')
        new_page.css('.r_3')
      end
    end
  end

  # convert this into a while or for loop
  highest_count = 0
  url_of_matched = ""
  highest_rated.each do |elem|
    temp = elem.ancestors[1].css('.ratdig').text.to_i

    if temp > highest_count
      highest_count = temp
      url_of_matched = elem.ancestors[2].css('.song').first['href']
    end

  end

  tabs_page = Nokogiri::HTML open(url_of_matched, 'User-Agent' => 'chrome')

  tabs = tabs_page.css('.tb_ct pre')[2].to_s
  File.open("#{song_title.gsub(' ','_')}.txt", 'w') do |file|
    file.puts Sanitize.fragment(tabs)
  end

rescue LoadError => e
  puts "#{e.message} gem not found... Installing"
  load_missing_gem e.message.split.last
  retry
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
