class Post

  attr_reader :name, :section, :basename, :metadata, :content

  def initialize(post_name)

    raise ArgumentError, 'posts must be initialized with a name in the form [section]/[filename w/out ext]' unless /^\w+\/\w+$/ === post_name 

    raise ArgumentError, "trying to create a post with the name #{post_name} failed because this file does not exist on the system." unless post_exists?(post_name)
    
    # the posts name is also its hash key - [section]/[file name without ext]
    @name = post_name
    @section, @basename = post_name.split('/') 
    @metadata, @content = parse_file

  end

  def parse_file
    # posts need to be relatively small files, as this method will consume a lot of memory if the files are large. Fine for my use.
    file_data = File.read(File.join(ENV['POSTS_DIR'], @name + ".mdown"))
    # TODO: check for proper formatting
    # raise "the post #{@name} is not formatted properly. Please see Starman doc for details.
    metadata_text, content = file_data.split("*-----*-----*")
    return parse_metadata(metadata_text), content.strip! 
  end

  def post_exists?(post_name)
    # only markdown posts are allowed
    return File.exist?(File.join(ENV['POSTS_DIR'], post_name + ".mdown"))
  end

  def parse_metadata(metadata_text)
    # parses date and entry summary, discards any extra metadata
    metadata = Hash.new
    metadata_text.lines.each do |mdata_line|
      if is_metadata?(mdata_line)
        #delimit on first colon 
        key, value = mdata_line.split(/\s*:\s*/, 2)
        case key.downcase
        when "date"
          # TODO date format localization
          metadata["date"] = DateTime.strptime(value, '%m/%d/%Y') 
        when "summary"
          metadata["summary"] = value[0..100].strip
        end #end case
      else p "not valid metadata: #{mdata_line}"
      end
    end
    return metadata
  end

  def is_metadata?(mdata_line)
    # metadata keywords must be named with letters, numbers, or underscores and separated from their values by a colon 
    mdata_line.match(/^[\w]+:.+/)
  end

end
