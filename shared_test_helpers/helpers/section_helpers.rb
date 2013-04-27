module SectionHelpers

  def create_and_add_section_posts_to_cache(section, trait_names)
    # post_names is an array of FactoryGirl post_data traits.. These posts will be created in the given section and added to the cache. Also assigns a bunch of instance variables for use in tests.
    Post.stub(:post_exists?).and_return(true)
    trait_names.each do |post_name|
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, post_name.to_sym)}
      instance_variable_set("@#{post_name}", Post.new("#{section}/#{post_name}"))
      app.settings.memcached.set(post_name, instance_variable_get("@#{post_name}"))
    end
    return trait_names 
  end

end

World(SectionHelpers) if respond_to?(:World)
