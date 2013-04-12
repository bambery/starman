require_relative 'spec_helper'
require_relative '../post.rb'
require 'factory_girl'
FactoryGirl.find_definitions

describe Post do
  context 'post creation' do

    before(:each) do
      Post.any_instance.stub(:post_exists?) { true }
      Post.any_instance.stub(:read_post_file) { FactoryGirl.create(:post_data) }
      @test_post = FactoryGirl.build(:properly_formatted_post)
    end

    it 'assigns the name' do
      @test_post.name.should eq("blog/goodbye_love")
    end

    it 'assigns the section' do
    end

    it 'assigns the basename' do 
    end

  end
end
