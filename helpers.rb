module Starman
  module CachingHelpers 
    def get_or_add_post_to_cache(post_path)
      post = settings.memcached.get(post_path)
      if post.nil? 
        post = Post.new(post_path)
        settings.memcached.set(post_path, post) 
      end
      return post
    end

    def get_or_add_section_to_cache(section)
      section_posts = settings.memcached.get(section)
      if section_posts.nil?
        new_sec = Section.new(section)
        sort_posts_by_date_and_add_to_cache!(new_sec)
        settings.memcached.set(new_sec.name, new_sec.posts)
      end
    end

    def sort_posts_by_date_and_add_to_cache!(section)
      # grab all posts in section, add them to the cache, sort them by date, then save the array of sorted post names on the section
      sec_posts = section.posts.map { |post_name| get_or_add_post_to_cache(post_name) }
      sec_posts.sort! { |a,b| b.date <=> a.date }
      sec_posts.map! { |post| post.name }
      section.posts = sec_posts
    end

  end

  module LogHelpers
    def add_error_to_log(e)
      logger.error("#{e.class.name}: #{e.message} \n #{e.backtrace.join("\n")}")
    end
  end
end
