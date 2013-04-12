require_relative 'spec_helper'
require_relative '../post.rb'
require 'factory_girl'
FactoryGirl.find_definitions

describe Post do
  context 'post creation' do

    before(:each) do
      @test_post = FactoryGirl.build(:post)
    end

    it 'assigns the name' do
      @test_post.name.should eq("blog/foo")
    end
  end
end
