module Starman
  module CachingHelpers 
    def get_or_add_post_to_cache(post_path)
      post = settings.memcached.get(post_path)
      if post.nil? 
        post = Post.new(post_path)
        settings.memcached.set(post_path, post) if post.is_valid? 
      end
      post.is_valid? ? post : nil

    end

  end

  module LogHelpers
    def add_error_to_log(e)
      logger.error("#{e.class.name}: #{e.message} \n #{e.backtrace.join("\n")}")
    end
  end
end
