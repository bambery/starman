module Starman 

  class StarmanError < StandardError
    attr :name
    def initialize(name)
      @name = name
    end
  end

  class SectionNotFound < StarmanError
    def message
      "A section with the name of #{@name} does not exist on the file system."
    end
  end

  class SectionEmpty < StarmanError
    def message
      "Section #{@name} contains no posts."
    end
  end

  class FileNotFoundError < StarmanError
    def message
      "Trying to create a post with the name #{@name} failed because this file does not exist on the system."
    end
  end
  
  class DigestNotFoundError < StarmanError
    def message
      "The file #{@name} does not have an entry in the manifest."
    end
  end

  class NameError < StarmanError
    def message
      "Posts must be initialized with a name in the form [section]/[filename]-[digest].mdown, #{@name} was passed in."  
    end
  end

  class DateError < StarmanError
    def message
      "#{@name}: This post is either missing a date or it is improperly formatted."
    end
  end

  class InvalidMetadata < StarmanError
    attr :name, :mdata_line
    def initialize(name, mdata_line) 
      @name = name
      @mdata_line = mdata_line
    end

    def message
      "Invalid metadata in post #{@name}: #{@mdata_line}. Metadata must be in the form of KEYWORD: VALUE" 
    end
  end

  class FormattingError < StarmanError
    def message
      "#{@name}: A post must have the *-----*-----* divider between the metadata and the content."
    end
  end

end
