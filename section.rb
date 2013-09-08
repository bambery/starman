module Starman
  class Section
    attr_reader :name
    attr_accessor :posts

    def initialize(name)
      @name = name
      @posts = get_compiled_posts 
    end

    ##
    # returns an array of the hash keys of posts in the section
    # 
    def get_compiled_posts
      raise Starman::SectionNotFound.new(name) unless Section.exists?(name)
      posts = Content.get_content(File.join(Content.compiled_content_dir, @name, '/*'))
      p "this is posts #{posts}"
      # return hash keys
      posts.map! { |post| post.gsub(Content.compiled_content_dir + "/", "") }
    end

    def self.exists?(section)
      return Dir.exists?(File.join(Content.compiled_content_dir, section))
    end
    
  end
end
