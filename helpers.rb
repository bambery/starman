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

    def get_or_add_section_to_cache(section)
      section_posts = settings.memcached.get(section)
      if section_posts.nil?
        new_sec = Section.new(section)
        section_posts = sort_posts_by_date_and_add_to_cache(new_sec)
        settings.memcached.set(new_sec.name, section_posts)
      end
      return section_posts 
    end

    def sort_posts_by_date_and_add_to_cache(section)
      # grab all posts in section, add them to the cache, sort them by date, then save the array of sorted post names on the section
      sec_posts = section.posts.map { |post_name| get_or_add_post_to_cache(post_name) }
      sec_posts.sort! { |a,b| b.date <=> a.date }
      sec_posts.map! { |post| post.name }
      return sec_posts
    end

  end

  module LogHelpers
    def add_error_to_log(e)
      logger.error("#{e.class.name}: #{e.message} \n #{e.backtrace.join("\n")}")
    end
  end
end
