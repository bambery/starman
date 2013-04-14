require_relative ('../../post.rb')

Given(/^there is a post in section (\w+) named (\w+)$/) do |section, post_name|
  Post.any_instance.should_receive(:post_exists?).and_return(true) 
  Post.any_instance.should_receive(:read_post_file) {FactoryGirl.create(:post_data)}
  @test_post = Post.new("meep/moop")
  p "my fhjfja #{@test_post.inspect}"
end
