require_relative 'base'

class Search < Base
  class << self

    def search_index(word)

      result = nil

      if word.length < 3
        # 2文字以下の場合、一文字ごとに検索
        for i in 0..word.length-1
          if result.nil?
            result = find_letter(word[i])
          else
            result = result & find_letter(word[i])
          end
          break if result.blank?
        end
      else
        # 3文字以上の場合、二文字ごとに検索
        i = 0
        while i < word.length - 1
          if result.nil?
            result = find_word(word.slice(i, 2))
          else
            result = result & find_word(word.slice(i, 2))
          end

          break if result.blank?
          i += 2
        end
        # 文字列が奇数の場合、最後の一文字を検索
        if i != word.length
          result = result & find_letter(word[-1])
        end
      end

      result
    end

    # Index fileから一文字のレコードを探す
    def find_letter(key)
      result = []
      index_file = search_file(key)

      return result unless File.exists?(index_file)

      File.foreach(index_file) do |line|
        word, post_codes = line.split("\t")

        if word.start_with?(key) && post_codes.present?
          result = result | post_codes.split(',')
        end
      end
      result
    end

    # Index fileから二文字の完全一致レコードを探す
    def find_word(key)
      result = []
      index_file = search_file(key)

      return result unless File.exists?(index_file)

      File.foreach(index_file) do |line|
        word, post_codes = line.split("\t")

        if word == key && post_codes.present?
          result = post_codes.split(',')
        end
      end
      result
    end

    def output_content(post_codes)
      return unless File.exists?(post_file)

      # post_codesをpostfileから探し、一致する住所を出力
      File.foreach(post_file) do |line|
        post, pref, city, town = line.split("\t")
        town.delete!("\n")

        if post_codes.include?(post)
          puts "\"#{post}\",\"#{pref}\",\"#{city}\",\"#{town}\""
          post_codes.delete(post)

          break if post_codes.blank?
        end
      end
    end

  end
end

while true
  print '検索するキーワードを入力してください(\qで終了します):'
  word = gets.strip
  break if %w(¥q \q).include?(word)

  word = word.delete(' ')

  if word.present?
    post_codes = Search.search_index(word)

    if post_codes.blank?
      puts "検索結果がありません"
    else
      Search.output_content(post_codes)
    end

  end
end