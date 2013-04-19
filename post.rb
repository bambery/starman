require 'date' 

class Post

  attr_reader :name, :section, :basename, :metadata, :content

  def initialize(post_name)

    
    # the posts name is also its hash key - [section]/[file name without ext]
    @name = post_name
    @section, @basename = get_section_and_basename
    @metadata, @content = parse_file

  end

  def get_section_and_basename
    if /^\w+\/\w+$/ === @name 
      @name.split('/')
    else
     raise Starman::NameError.new(@name)
    end
  end

#  def is_valid?
#    !(@name.nil? || @section.nil? || @basename.nil? || @metadata.nil? || @content.nil?)
#  end

#  def ==(other)
#    if 
#      self.class == other.class &&
#      @name == other.name &&
#      @section == other.section &&
#      @basename == other.basename &&
#      @metadata == other.metadata &&
#      @content == other.content 
#      return true
#    else
#      return false
#    end
#  end

  def parse_file
    if ENV['POSTS_DIR'].nil?
#      raise StarmanErrors::ConfigError, "The config which contains the env vars is not being loaded."
    elsif !Post.post_exists?(@name)
      raise Starman::FileNotFoundError.new(@name)
    end

    file_data = read_post_file 
    # TODO: better check for proper formatting
    # raise "the post #{@name} is not formatted properly. Please see Starman doc for details.
    if !file_data.include?("*-----*-----*")
      raise Starman::FormattingError.new(@name)
    end
    metadata_text, content = file_data.split("*-----*-----*")
    return parse_file_data(metadata_text.strip, content.strip)
  end

  def read_post_file
    # posts need to be relatively small files, as this method will consume a lot of memory if the files are large. Fine for my use.
    File.read(File.join(ENV['POSTS_DIR'], @name + ".mdown"))
  end

  def self.post_exists?(post_name)
    # only markdown posts are allowed
    return File.exist?(File.join(ENV['POSTS_DIR'], post_name + ".mdown"))
  end

  def parse_file_data(metadata_text, content)
    # parses date and entry summary, discards any extra metadata
    metadata = Hash.new
    required_data = ["date", "summary"]
    required_data << "content" if content.empty?
    metadata_text.lines.each do |mdata_line|
      mdata_line.strip!
      next if mdata_line.empty?
      raise Starman::InvalidMetadata.new(@name, mdata_line) unless is_metadata?(mdata_line)
      #delimit on first colon 
      key, value = mdata_line.split(/\s*:\s*/, 2)
      case key.downcase
        when "date"
          # TODO date format localization
          # TODO custom exception to capture improperly formatted dates and 404 on entry
          raise Starman::DateError.new(@name) if value.strip.empty?
          begin
            metadata["date"] = DateTime.strptime(value, '%m/%d/%Y') 
          rescue ArgumentError
            raise Starman::DateError.new(@name)
          end
          required_data.delete("date")
        when "summary"
          if !value.strip.empty?
            metadata["summary"] = value[0..100].strip
            required_data.delete("summary")
          end
      end #end case
    end # end do
      
    # handle missing required fields
    if !required_data.empty?
      required_data.each do |item|
        case item
          when "date"
            # TODO need a custom exception to handle this so app doesn't blow up on empty entries, should 404 instead
            raise Starman::DateError.new(@name) 
          when "summary"
            content = "This entry is empty. Please write something here!" if content.empty? 
            required_data.delete("content") {required_data}
            metadata["summary"] = content[0..100].strip 
          when "content"
            content = "This entry is empty. Please write something here!" if content.empty? 
        end # end case
      end # end do
    end # end if

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

end
