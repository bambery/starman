require 'date' 

class Post

  attr_reader :name, :section, :basename, :metadata, :content

  def initialize(post_name)

    raise SystemCallError, "You're not loading the config which contains the env vars." if ENV['POSTS_DIR'].empty?

    raise NameError, 'posts must be initialized with a name in the form [section]/[filename w/out ext]' unless /^\w+\/\w+$/ === post_name 

    raise ArgumentError, "trying to create a post with the name #{post_name} failed because this file does not exist on the system." unless post_exists?(post_name)
    
    # the posts name is also its hash key - [section]/[file name without ext]
    @name = post_name
    @section, @basename = post_name.split('/') 
    @metadata, @content = parse_file

  end

  def parse_file
    file_data = read_post_file 
    # TODO: check for proper formatting
    # raise "the post #{@name} is not formatted properly. Please see Starman doc for details.
    metadata_text, content = file_data.split("*-----*-----*")
    return parse_file_data(metadata_text.strip, content.strip)
  end

  def read_post_file
    # posts need to be relatively small files, as this method will consume a lot of memory if the files are large. Fine for my use.
    File.read(File.join(ENV['POSTS_DIR'], @name + ".mdown"))
  end

  def post_exists?(post_name)
    # only markdown posts are allowed
    return File.exist?(File.join(ENV['POSTS_DIR'], post_name + ".mdown"))
  end

  def parse_file_data(metadata_text, content)
    # parses date and entry summary, discards any extra metadata
    metadata = Hash.new
    required_data = ["date", "summary"]
    required_data << "content" if content.empty?
    metadata_text.lines.each do |mdata_line|
      if is_metadata?(mdata_line)
        #delimit on first colon 
        key, value = mdata_line.split(/\s*:\s*/, 2)
        case key.downcase
          when "date"
            # TODO date format localization
            # TODO custom exception to capture improperly formatted dates and 404 on entry
            metadata["date"] = DateTime.strptime(value, '%m/%d/%Y') 
            required_data.delete("date")
          when "summary"
            metadata["summary"] = value[0..100].strip
            required_data.delete("summary")
        end #end case
      else p "not valid metadata: #{mdata_line}"
      end #end if
    end # end do
      
    # handle missing required fields
    if !required_data.empty?
      required_data.each do |item|
        case item
          when "date"
            # TODO need a custom exception to handle this so app doesn't blow up on empty entries, should 404 instead
            raise ArgumentError, "Posts must have a date defined on them: #{post_name}"
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
    mdata_line.match(/^[\w]+:.+/)
  end

end
