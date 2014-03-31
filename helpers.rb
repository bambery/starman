module Starman
  module CachingHelpers 

    ##
    # Attempt to find the post in the cache, if not there, place it there.
    #
    # Default is to pass in a post by section/post_name without digest or 
    # format and then do a lookup in the manifest to find the compiled name.
    #
    # Check the cache with the digest name as key.
    # If not found, process the digest file and throw it in memcached
    #
    def get_or_add_post_to_cache(post_path)
      # For better or worse, I've just enforced that all posts must be .mdown
      # key also now has .mdown at the end - will have consequences 
      post_digest_path = Content.newest_post_digest(post_path)
      raise Starman::DigestNotFoundError.new(post_path) unless post_digest_path
      post = settings.memcached.get(post_digest_path)
      if post.nil? 
        post = Post.new(post_digest_path)
        settings.memcached.set(post_digest_path, post) 
      end
      return post
    end

    ##
    # At asset compile, section folders have a proxy file created for them based 
    # on the contents of the section. The proxy's digest is used as the cache 
    # key to track changes in the section.
    # returns an array of fingerprinted memcached keys pointing to posts
    #
    def get_or_add_section_to_cache(section_name)
      section_digest = Content.newest_section_digest(section_name)
      section = settings.memcached.get(section_digest)
      if section.nil?
        new_section = Section.new(section_name, section_digest)
        new_section.posts = sort_posts_by_date_and_add_to_cache(new_section.posts)
        settings.memcached.set(section_digest, new_section)
        section = new_section 
      end
      return section 
    end

    ##
    # Grab all posts in section, add them to the cache, sort them by date, 
    # then save the array of sorted post names on the section
    #
    # look at 
    # http://awaxman11.github.io/blog/2013/10/11/sorting-a-rails-resource-based-on-a-calculated-value/
    def sort_posts_by_date_and_add_to_cache(sec_posts)
      sec_posts.map! { |digest_post_name| get_or_add_post_to_cache(digest_post_name) }
      sec_posts.sort! { |a,b| b.date <=> a.date }
      # only return the array of names
      sec_posts.map! { |post| post.digest_name }
      return sec_posts
    end

  end

end
