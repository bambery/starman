class Section
  attr_reader :name
  attr_accessor :posts

  def initialize(name)
    @name = name
    @posts = find_posts
  end

  def self.compiled_content_dir
    CloudCrooner.manifest.dir
  end

  def find_posts
    raise Starman::SectionNotFound.new(@name) unless Section.exists?(@name)
    # exclude any dotfiles
    posts = Dir.entries(File.join(Section.compiled_content_dir, @name)).delete_if {|i| i =~ /^\./} 
    if posts.size == 0 then raise Starman::SectionEmpty.new(@name) end 
    # get an array of the posts's hash keys
    posts.map! { |post| File.join(@name, post) }
    return posts
  end

  def self.exists?(section)
    return Dir.exists?(File.join(compiled_content_dir, section))
  end

end
