module Starman
  class Section
    attr_reader :name, :digest_name, :cache_key
    attr_accessor :posts

    def initialize(name, digest)
      # The section's digest_name is its memcached key
      @name = name
      @digest_name = digest
      @posts = get_posts
    end

    ##
    # Find all posts in the section, excluding posts that were not compiled. 
    # Returns an unsorted array of the names of the section's posts.  
    #
    # Can't sort by date here since I don't have access to the cache, and 
    # reading and parsing posts is expensive.
    # 
    def get_posts
      raise Starman::SectionNotFound.new(section_name) unless Section.exists?(section_name)
      posts = Dir.glob(File.join(Content.raw_content_dir, @name, '/*')) 
      # remove content dir in path to return hash keys
      posts.map! { |post| post.gsub(Content.compiled_content_dir + "/", "") }
      # Remove files without an entry in the manifest. 
      posts.keep_if { |post| Content.newest_post_digest(post) }
    end

    ##
    # I mean, Jesus, I hope we couldn't get this far with a ghost dir, 
    # but better safe etc 
    #
    def self.exists?(section)
      return Dir.exists?(File.join(Content.raw_content_dir, section))
    end
   
  end
end
