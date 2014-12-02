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

  # song_match = matched_titles.select do |match|

  # end

  matched

  highest_rated_matched = matched_titles.map do |match|

    # views = match.css('.ratdig').text.to_i
    # if !match.css('.rating').empty?
    #   rating = rating[match.css('.rating').last.child["class"]]
    # else
    #   rating = 0
    # end
  end

rescue LoadError => e
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
