
class Base
  class << self
    INDEX_PATH = "#{Rails.root}/etc/index"

    def post_file
      "#{INDEX_PATH}/post.tsv"
    end

    def search_file(letter)
      return nil unless letter.present? && letter.is_a?(String)
      "#{INDEX_PATH}/#{letter.ord}.tsv"
    end
  end
end
