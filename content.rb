module Starman
  module Content

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

  end
end
