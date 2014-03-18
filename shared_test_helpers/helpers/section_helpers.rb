module SectionTestHelpers

# this looks like it was for cukes back in the day. Might want it later,
# commenting out for now
#
#  def create_and_add_section_posts_to_cache(app, section, trait_names)
#    # post_names is an array of FactoryGirl post_data traits. These posts will be created in the given section and added to the cache. Also assigns a bunch of instance variables for use in tests.
#    Starman::Post.stub(:exists?).and_return(true)
#    trait_names.each do |post_name|
#      Starman::Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, post_name.to_sym)}
#      instance_variable_set("@#{post_name}", app.new.get_or_add_post_to_cache("#{section}/#{post_name}"))
#      app.new.settings.memcached.set("#{section}/#{post_name}", instance_variable_get("@#{post_name}"))
#    end # do
#    return trait_names 
#  end
#
end

World(SectionTestHelpers) if respond_to?(:World)
