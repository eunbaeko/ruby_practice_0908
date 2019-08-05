require 'optparse'
require 'fileutils'
require 'objspace'

class CreateIndex
  class << self
    INDEX_PATH = 'etc/index'

    def post_file
      "#{INDEX_PATH}/post.tsv"
    end

    def search_file(letter)
      return nil unless letter.present? && letter.is_a?(String)
      "#{INDEX_PATH}/#{letter.ord}.tsv"
    end

    def create_dictionary(resource_path, encoding)

      return nil unless File.exists?(resource_path)

      dic = {}
      File.foreach(resource_path, encoding: "#{encoding}:UTF-8") do |line|
        items = line.split(',').map{ |word| word.delete('"') }
        post = items[2]
        pref, city, town = items.slice(6, 3)

        next if post.blank?

        if dic[post].present?
          addr = dic[post]
          dic[post] = [addr[0], addr[1], "#{addr[2]}#{town}"]
        else
          dic[post] = [pref, city, town]
        end
      end

      dic
    end

    def write_post_index(dic)
      if Dir.exists?(INDEX_PATH)
        print 'Index directory is exists. Are you sure remove and re-create it?(y/n):'
        return false unless gets.strip == 'y'
        FileUtils.rm_rf(INDEX_PATH)
      end

      FileUtils.mkdir(INDEX_PATH)

      f = File.new(post_file, "w", 0755)

      dic.each do |post, addr|
        pref, city, town = addr
        f.puts "#{post}\t#{pref}\t#{city}\t#{town}"
      end

      f.close

      true
    end

    def create_index_hash(dic)
      index_hash = {}

      dic.each do |post, addr|
        full_addr = addr.join.delete(' ')
        for i in 0..full_addr.length-1
          word = full_addr.slice(i, 2)
          letter = word.first

          word_hash = index_hash[letter]
          if word_hash.blank?
            word_hash = {}
            index_hash[letter] = word_hash
          end

          if word_hash.has_key?(word)
            word_hash[word] << post
          else
            word_hash[word] = [post]
          end
        end
      end

      index_hash
    end

    def write_search_index(index_hash)
      index_hash.each do |letter, word_hash|
        file_path = search_file(letter)
        next unless file_path.present?

        if File.exists?(file_path)
          File.delete(file_path)
        end

        f = File.new(file_path, "w", 0755)
        word_hash.each do |word, post_arr|
          f.puts "#{word}\t#{post_arr.join(',')}"
        end
        f.close
      end
    end
  end
end

t = Time.now

opts = ARGV.getopts('', 'path:', 'encoding:')
path = opts['path']
encoding = opts['encoding']

path = 'etc/resource/KEN_ALL.CSV' if path.blank?
encoding = 'Shift_JIS' if encoding.blank?

dic = CreateIndex.create_dictionary(path, encoding)

unless dic.present?
  puts 'fail'
  exit
end

puts "dic created : #{Time.now - t}sec"

unless CreateIndex.write_post_index(dic)
  puts 'cancel'
  exit
end

puts "wrote post index : #{Time.now - t}sec"

index_hash = CreateIndex.create_index_hash(dic)

puts "index hash created : #{Time.now - t}sec"

puts "#{ObjectSpace.memsize_of_all * 0.001 * 0.001} MB"
puts "#{ObjectSpace.memsize_of_all * 0.001} KB"

CreateIndex.write_search_index(index_hash)

puts "wrote index files : #{Time.now - t}sec"