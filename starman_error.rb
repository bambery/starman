module Starman 

  class StarmanError < StandardError
    attr :name
    def initialize(name)
      @name = name
    end
  end

  class FileNotFoundError < StarmanError
    def message
      "Trying to create a post with the name #{@name} failed because this file does not exist on the system."
    end
  end

  class NameError < StarmanError
    def message
      "Posts must be initialized with a name in the form [section]/[filename w/out ext], #{@name} was passed in."  
    end
  end

  class MissingDate < StarmanError
    def message
      "Posts must have a date defined on them: #{@name}"
    end
  end

  class FormattingError < StarmanError
    def message
      "#{@name}: A post must have the *-----*-----* divider between the metadata and the content."
    end
  end

end
