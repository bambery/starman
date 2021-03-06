require 'date' 

module Starman
  class Post

    attr_reader :name, :digest_name, :section, :basename, :metadata, :content

    ##
    # The posts's digest name is also its memcached key: 
    #   [section]/[digest file name].mdown
    #
    #   FIXME: post and sections are initialized with different number of 
    #   arguments, but post still needs @name, just strips it rather than 
    #   expects it passed in
    #
    def initialize(digest_post_name)
      @section, @basename = get_section_and_basename(digest_post_name)
      @name = digest_post_name.gsub(/-[0-9a-z]*\.mdown/, "")
      @digest_name = digest_post_name
      @metadata, @content = parse_file
    end

    def get_section_and_basename(digest_post_name)
      if /^\w+\/\w+-[0-9a-z]*\.mdown/ === digest_post_name 
        digest_post_name.split('/')
      else
       raise Starman::NameError.new(digest_post_name)
      end
    end

    # this is only used in testing, pull out into helper
    def ==(other)
      self.class == other.class &&
      @digest_name == other.digest_name &&
      @section == other.section &&
      @basename == other.basename &&
      @metadata == other.metadata &&
      @content == other.content 
    end

    ##
    # Read in the fingerprinted markdown file and separate into metadata and 
    # content at the delimiter.
    #
    def parse_file
      raise Starman::FileNotFoundError.new(@digest_name) unless Post.exists?(@digest_name) 

      file_data = read_post_file 
      # TODO: better check for proper formatting
      unless file_data.include?("*-----*-----*-----*")
        raise Starman::FormattingError.new(@digest_name)
      end
      metadata_text, content = file_data.split("*-----*-----*-----*")
      parse_file_data(metadata_text.strip, content.strip)
    end

    # ##
    # Read markdown file into memory for processing.
    # Posts need to be relatively small files as this method will 
    # consume a lot of memory if the files are large. Fine for my use.
    #
    def read_post_file
      File.read(File.join(Content.compiled_content_dir, @digest_name))
    end

    ##
    # Check if the fingerprinted post exists on the file system.
    #
    def self.exists?(post_name)
      File.exist?(File.join(Content.compiled_content_dir, post_name))
    end

    ##
    # Parse date, entry summary and title; discards extra metadata.
    # If summary or title is missing or the content is empty, default data are
    # supplied; if date is missing, it will fail
    #
    def parse_file_data(metadata_text, content)
      metadata = Hash.new
      required_data = ["date", "summary", "title"]
      required_data << "content" if content.empty?
      metadata_text.lines.each do |mdata_line|
        # remove surrounding whitespace. If line is empty or invalid format, skip
        mdata_line.strip!
        next if mdata_line.empty?
        raise Starman::InvalidMetadata.new(@digest_name, mdata_line) unless is_metadata?(mdata_line)
        #delimit on first colon 
        key, value = mdata_line.split(/\s*:\s*/, 2)
        case key.downcase
          when "date"
            # TODO date format localization
            raise Starman::DateError.new(@digest_name) if value.strip.empty?
            begin
              metadata["date"] = DateTime.strptime(value, '%m/%d/%Y') 
            rescue ArgumentError
              raise Starman::DateError.new(@digest_name)
            end
            required_data.delete("date")
          when "summary"
            if !value.strip.empty?
              metadata["summary"] = value[0..100].strip
              required_data.delete("summary")
            end
          when "title"
            if !value.strip.empty?
              metadata["title"] = value[0..40]
              required_data.delete("title")
            end
        end #end case
      end # end do

      metadata, content = populate_missing_fields(required_data, metadata, content) unless required_data.empty?

      return metadata, content
    end

    def populate_missing_fields(required_data, metadata, content)
      required_data.each do |item|
        case item
          when "date"
            # a post must have a date since section depends on it
            raise Starman::DateError.new(@digest_name) 
          when "summary"
            content = "This entry is empty. Please write something here!" if content.empty? 
            required_data.delete("content") 
            metadata["summary"] = content[0..100].strip 
          when "content"
            content = "This entry is empty. Please write something here!" if content.empty? 
          when "title"
            # default title is the file name
            default_title = @basename.gsub(/-[0-9a-z]*\.mdown/, "")
            metadata["title"] = default_title.split('_').map(&:capitalize).join(' ')
        end # end case
      end # end do
      return metadata, content
    end


    def is_metadata?(mdata_line)
      # metadata keywords must be named with letters, numbers, or underscores and separated from their values by a colon 
      mdata_line.match(/^\s*[\w]+\s*:.*/)
    end

    def date
      metadata["date"]
    end

    def summary
      metadata["summary"]
    end

    def title
      metadata["title"]
    end

  end
end
