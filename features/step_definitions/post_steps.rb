require_relative ('../../post.rb')

Given(/^there is a post in section (\w+) named (\w+)$/) do |section, name|
  Post.stub(:post_exists?).and_return(true) 
  @post_content = FactoryGirl.create(:content)
  Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data, content: @post_content)}
  @test_post = Post.new("#{section}/#{name}")
end

When(/^I attempt to access the post$/) do
  visit("/" + @test_post.name)
end

Then(/^I am shown the post$/) do
  @post_content_attributes = FactoryGirl.attributes_for(:content)
  page.should have_content(@post_content_attributes["title"])
  page.should have_content(@post_content_attributes["post_entry"])
end
