module Starman
  module CachingHelpers 

    def manifest
      @manifest ||= CloudCrooner.manifest
    end

    ##
    # Attempt to find the post in the cache. First do a manifest lookup
    # to find the most recent digest, then check the cache for the digest name.
    # If not found, process the digest file and throw it in memcached
    #
    def get_or_add_post_to_cache(post_path)
      # For better or worse, I've just enforced that all posts must be .mdown
      # key also now has .mdown at the end - will have consequences 
      post_digest_path = newest_post_digest(post_path)
      post = settings.memcached.get(post_digest_path)
      if post.nil? 
        post = Post.new(post_digest_path)
        settings.memcached.set(post_digest_path, post) 
      end
      return post
    end

    ##
    # check the manifest for the most recent fingerprinted name for a post
    #
    def newest_post_digest(post_path)
      manifest.assets[post_path + '.mdown'] ||
        (raise Starman::DigestNotFoundError.new(post_path))
    end

    def newest_section_digest(section)
      manifest.assets[section] ||
        (raise Starman::DigestNotFoundError.new(section))
    end

    ##
    # At asset compile, section folders have a proxy file created for them based 
    # on the contents of the section. The proxy's digest is used as the cache 
    # key to track changes in the section.
    #
    def get_or_add_section_to_cache(section_name)
      section_digest = newest_section_digest(section)
      section_posts = settings.memcached.get(section_digest)
      if section_posts.nil?
        new_sec = Section.new(section_name)
        section_posts = sort_posts_by_date_and_add_to_cache(new_sec)
        settings.memcached.set(section_digest, section_posts)
      end
      return section_posts 
    end

    ##
    # Grab all posts in section, add them to the cache, sort them by date, 
    # then save the array of sorted post names on the section
    #
    def sort_posts_by_date_and_add_to_cache(section)
      sec_posts = section.posts.map { |post_name| get_or_add_post_to_cache(post_name) }
      sec_posts.sort! { |a,b| b.date <=> a.date }
      sec_posts.map! { |post| post.name }
      return sec_posts
    end

  end

end
