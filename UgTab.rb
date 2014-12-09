class UgTab
  require 'nokogiri'
  require 'open-uri'
  require 'sanitize'

  def initialize(*argument)
    @song_title = argument[0]
    value = @song_title.gsub ' ', '+'
    @url = "http://www.ultimate-guitar.com/search.php?search_type=title&value=#{value}"
  end

  def get_tab!
    page = Nokogiri::HTML open(@url, 'User-Agent' => 'chrome')
    results_row = page.css('.tresults').first.css 'tr'

    matched_results = results_row.select do |result|
      chords_or_tabs?(result) && matched_title?(result)
    end

    matched_song_url = highest_matched_song(matched_results)
    create_text_file(matched_song_url)
  end

  private

    def create_text_file(url_of_matched)
      tabs_page = Nokogiri::HTML open(url_of_matched, 'User-Agent' => 'chrome')

      tabs = tabs_page.css('.tb_ct pre')[2].to_s
      File.open("#{@song_title.gsub(' ','_')}.txt", 'w') do |file|
        file.puts Sanitize.fragment(tabs)
      end
    end

    def matched_title?(result)
      return false if result.css('.song').empty?
      result.css('.song').last.attributes["class"].value == "song" && result.css('.song').last.text.downcase.match(@song_title)
    end

    def chords_or_tabs?(result)
      return false if result.css('td strong').empty?
      %w(chords tab).include? result.css('td strong').last.text.downcase
    end

    def highest_matched_song(matched_titles)
      new_page = Nokogiri::HTML matched_titles.columnize

      highest_rated_songs = match_highest_rated_records(new_page)
      select_url_of_match(highest_rated_songs)

    end

    def select_url_of_match(highest_rated)
      highest_count = 0
      url_of_matched = ""
      highest_rated.each do |elem|
        temp = elem.ancestors[1].css('.ratdig').text.to_i

        if temp > highest_count
          highest_count = temp
          url_of_matched = elem.ancestors[2].css('.song').last['href']
        end

      end
      return url_of_matched
    end

    def match_highest_rated_records(new_page) 
      return new_page.css(".r_5") if !new_page.css(".r_5").empty?
      return new_page.css(".r_4") if !new_page.css(".r_4").empty?
      return new_page.css(".r_3") if !new_page.css(".r_3").empty?
    end

end