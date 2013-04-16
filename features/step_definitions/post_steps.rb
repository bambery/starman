require_relative ('../../post.rb')

Given(/^there is a post in section (\w+) named (\w+)$/) do |section, name|
  Post.any_instance.should_receive(:post_exists?).and_return(true) 
  Post.any_instance.should_receive(:read_post_file) {FactoryGirl.create(:post_data)}
  @test_post = Post.new("#{section}/#{name}")
end

When(/^I attempt to access the post$/) do
  visit("/" + @test_post.name)
end

Then(/^I am shown the post$/) do
  page.should have_content(@test_post.content)
end
