module Starman
  class Section
    attr_reader :name
    attr_accessor :posts

    def initialize(name)
      @name = name
      @posts = get_compiled_posts 
    end

    ##
    # returns an unsorted array of the hash keys of posts in the section
    #
    # Can't sort by date here since I don't have access to the cache, and 
    # reading and parsing posts is expensive.
    # 
    # FIXME: issue right here if I wanted sections to work with local_dynamic
    #
    def get_compiled_posts
      raise Starman::SectionNotFound.new(name) unless Section.exists?(name)
      posts = Content.get_content(File.join(Content.compiled_content_dir, @name, '/*'))
      # remove content dir in path to return hash keys
      posts.map! { |post| post.gsub(Content.compiled_content_dir + "/", "") }
    end

    # FIXME: will not work with local_dynamic
    def self.exists?(section)
      return Dir.exists?(File.join(Content.compiled_content_dir, section))
    end
    
    # reassign the sorted posts to the section instance 
    def posts=(sorted_posts)
      @posts = sorted_posts
    end

  end
end
