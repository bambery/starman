require './starman_error'
module Starman
  module Content

    ## 
    # Manage between compiled and uncompiled site content
    #

    def self.manifest
      CloudCrooner.manifest
    end

    ##
    # location of the compiled assets. In 'public/assets' by default
    # 
     def self.compiled_content_dir
      CloudCrooner.manifest.dir
    end

    ##
    # Gather the content requested by the glob minus directories 
    #
    # FIXME: move into Section class
    #
    def self.get_content(directory_glob)
      content = Dir.glob(directory_glob)
      # exclude directories
      content.select { |item| File.file?(item) }
      raise Starman::SectionEmpty.new(directory_glob) if content.size == 0 
      return content
    end

    ##
    # location of unprocessed "raw" content
    #
    def self.raw_content_dir
      File.join(__dir__, 'content')
    end

    ##
    # Check the manifest for the most recent fingerprinted name for a post
    # Return nil if not found
    #
    def self.newest_post_digest(post_path)
#      manifest.assets[post_path + '.mdown'] ||
#        (raise Starman::DigestNotFoundError.new(post_path))
      manifest.assets[post_path + '.mdown'] 
    end

    def self.newest_section_digest(section)
#      manifest.assets['proxies/'+ section +'-proxy.json'] ||
#        (raise Starman::DigestNotFoundError.new(section))
      manifest.assets['proxies/' + section + '-proxy.json'] 
    end

  end
end
