class Post

  def initialize(post_name)

    raise ArgumentError, 'posts must be initialized with a name in the form [section]/[filename w/out ext]' unless /^\w+\/\w+$/ === post_name 
    
    # the posts name is also its hash key - [section]/[file name without ext]
    @name = post_name
    @section, @basename = post_name.split('/') 

  end
end
