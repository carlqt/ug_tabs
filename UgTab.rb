class UgTab
  def initialize(*argument)
    @song_title = argument[0]
    value = @song_title.gsub ' ', '+'
    @url = "http://www.ultimate-guitar.com/search.php?search_type=title&value=#{value}"
  end

  def get_tab!
    page = Nokogiri::HTML open @url, 'User-Agent' => 'chrome'
    results_row = page.css('.tresults').first.css 'tr'

    matched_results = results_row.select do |result|
      chords_or_tabs?(result) && matched_title?(result)
    end

    matched_tab = highest_matched_song(matched_titles)
  end

  private

    def matched_title?(result)
      return false if result.css('.song').empty?
      result.css('.song').last.attributes["class"].value == "song" && result.css('.song').last.text.downcase.match(@song_title)
    end

    def chords_or_tabs?(result)
      return false if result.css('td strong').empty?
      %w(chords tab).include? result.css('td strong').last.text.downcase
    end

    def highest_match_song(matched_titles)
      new_page = Nokogiri::HTML matched_titles.columnize

      if !new_page.css('.r_5').empty?
        new_page.css('.r_5')
      else
        if !new_page.css('.r_4').empty?
          new_page.css('.r_4')
        else
          if !new_page.css('.r_3').empty?
            new_page.css('.r_3')
          end
        end
      end

    end

end