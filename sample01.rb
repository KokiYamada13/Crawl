require 'open-uri'
require 'nokogiri'
require 'anemone'


class Crawl
    def input
        input_line = ARGV[0].to_s
    end

    def url(input)
        address = 'https://en.wikipedia.org/wiki/' + input
    end

    def find_unexplored(tree, unexplored_key, key, input_value)
        tree.each do |a|
            if unexplored_key.include?(a)
                a
            else
                a = a.concat('$')
            end
        end

        tree.push(key)
        tree.unshift(input_value)
        puts tree
        exit
    end

    def add(key, tree, href)
        if key != '英語'
            tree.push(key)
            href.push(key)
        end
    end
end

PATH = '//*[@id="mw-content-text"]/div/p[1]/a'

crawl = Crawl.new

input_value = crawl.input
url = crawl.url(input_value)

tree = []
href = []
unexplored = []
end_sign = false

Anemone.crawl(url, :delay => 1, :skip_query_strings => true, :verbose => true, :depth_limit => 0) do |anemone|
    anemone.on_every_page do |page|
        page.doc.xpath(PATH).each do |link|
            key = link[:href]
            key.slice!('/wiki/')

            tree.each do |t|
                if key == t
                    key.concat('@')
                    end_sign = true
                    break
                end
            end

            if end_sign == true
                crawl.find_unexplored(tree, href, key, input_value)
            end

            crawl.add(key, tree, href)
        end
    end
end


href.each_with_index do |value, i|

    url = crawl.url(value)
    unexplored.push(value)

    Anemone.crawl(url, :delay => 1, :skip_query_strings => true, :verbose => true, :depth_limit => 0) do |anemone|
        anemone.on_every_page do |page|
            page.doc.xpath(PATH).each do |link|
                key = link[:href]
                key.slice!('/wiki/')

                tree.each do |t|
                    if key == t
                        key.concat('@')
                        end_sign = true
                        break
                    end
                end

                if end_sign == true
                    crawl.find_unexplored(tree, unexplored, key, input_value)
                end

                crawl.add(key, tree, href)
            end
        end
    end

    break if i == 19
end

# ツリーを出力
tree.unshift(input_value)
puts tree
