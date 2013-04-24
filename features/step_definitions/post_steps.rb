require_relative ('../../post.rb')

Given(/^there is a post in section (\w+) named (\w+)$/) do |section, name|
  Post.stub(:post_exists?).and_return(true) 
  @post_content = FactoryGirl.create(:content)
  Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, content: @post_content)}
  @test_post_name = "#{section}/#{name}"
  @test_post = Post.new(@test_post_name)
end

When(/^I attempt to access the post$/) do
  visit("/" + "#{@test_post_name}")
end

Then(/^I am shown the post$/) do
  @post_content_attributes = FactoryGirl.attributes_for(:content)
  page.should have_content(@post_content_attributes["title"])
  page.should have_content(@post_content_attributes["post_entry"])
end

Given(/^there is not a post in section (\w+) named (\w+)$/) do |section, name|
  @test_post_name = "#{section}/#{name}"
  expect(Post.post_exists?("#{@test_post_name}")).to be_false 
end

Then(/^I am shown file not found$/) do
  page.status_code.should be(404)
  #TODO test the page that was rendered to make sure it's the custom 404 page?
end

Given(/^a section named (\w+) with 3 posts$/) do |section|
  # there is a content factory for each item in the array, call it when creating and save a copy of the post in an instance variable with the same item name
  @section = section
  Post.stub(:post_exists?).and_return(true) 
  @section_posts = [ "best_post", "second_best", "ok_post" ] 
  @section_posts.each do |post_name|
    Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, post_name.to_sym)}
    instance_variable_set("@#{post_name}", Post.new("#{section}/#{post_name}"))
  end
end

When(/^I visit the section's index$/) do
  visit("/" + @section) 
end

Then(/^I am provided links to the section's entries and their summaries$/) do
  @section_posts.each do |post_name|
    has_link?(instance_variable_get("@#{post_name}").name).should be_true
    has_text?(instance_variable_get("@#{post_name}").summary).should be_true
  end
end

Given(/^there is not a section named foo$/) do
    pending # express the regexp above with the code you wish you had
end
