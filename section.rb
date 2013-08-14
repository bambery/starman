class Section
  attr_reader :name
  attr_accessor :posts

  def initialize(name)
    @name = name
    @posts = find_posts
  end

  def find_posts
    raise Starman::SectionNotFound.new(@name) unless Section.exists?(@name)
    # exclude any dotfiles
    posts = Dir.entries(File.join(ENV['POSTS_DIR'], @name)).delete_if {|i| i =~ /^\./} 
    if posts.size == 0 then raise Starman::SectionEmpty.new(@name) end 
    # get an array of the posts's hash keys
    posts.map! { |post| File.join(@name, post.chomp(File.extname(post))) }
    return posts
  end

  def self.exists?(section)
    return Dir.exists?(File.join(ENV['POSTS_DIR'], section))
  end

end
