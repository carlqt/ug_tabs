require 'pry'
def load_missing_gem(name, version=nil)

  begin
    gem name, version
  rescue LoadError
    version = "--version '#{version}'" unless version.nil?
    system("gem install #{name} #{version}")
    Gem.clear_paths
    retryi
  end

  # require name
end


begin
  require_relative 'UgTab'
  song = UgTab.new(ARGV[0]).get_tab!
rescue LoadError => e
  puts "#{e.message.split.last} gem not found... Installing"
  load_missing_gem e.message.split.last
  retry
end