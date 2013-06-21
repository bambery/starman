require_relative ('../../post.rb')

Given(/^there is a post in section (\w+) named (\w+)$/) do |section, name|
  Post.stub(:exists?).and_return(true) 
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
  expect(Post.exists?("#{@test_post_name}")).to be_false 
end

Then(/^I am shown file not found$/) do
  page.status_code.should be(404)
  #TODO test the page that was rendered to make sure it's the custom 404 page?
end

Given(/^a section named (\w+) with posts ([\w\,\s]+)$/) do |section, name_list|
  @section = section
  post_names_list = name_list.split(", ")
  @section_post_names = post_names_list.dup 
  Dir.stub(:entries) {create_and_add_section_posts_to_cache(@section, post_names_list) }
end

When(/^I visit the section's index$/) do
  visit("/" + @section) 
end

Then(/^I am provided links to the section's entries$/) do
  @section_post_names.each do |post_name|
    has_link?(instance_variable_get("@#{post_name}").title).should be_true
  end
end

Then(/^I am provided with their summaries$/) do
  @section_post_names.each do |post_name|
    has_text?(instance_variable_get("@#{post_name}").summary).should be_true
  end
end

Given(/^there is not a section named (\w+)$/) do |section|
  @section = section 
  expect(Section.exists?("#{@section}")).to be_false 
end
