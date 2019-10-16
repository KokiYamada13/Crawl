require 'open-uri'
require 'nokogiri'
require 'anemone'


input_line = ARGV[0].to_s
tree = []
result = []

# URL
url = 'https://en.wikipedia.org/wiki/' + input_line
PATH = '//*[@id="mw-content-text"]/div/p[1]/a'

Anemone.crawl(url, :redirect_limit => 1, :delay => 1, :skip_query_strings => true, :verbose => true, :depth_limit => 0) do |anemone|
    anemone.on_every_page do |page|
        page.doc.xpath(PATH).each do |link|
            key = link[:href]
            key.slice!('/wiki/')

            tree.each do |t|
                if key == t
                    key.concat('@')
                    tree.push(key)
                    break
                end
            end
        end
    end
end
