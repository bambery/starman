require_relative 'spec_helper'
require_relative '../post.rb'
require 'factory_girl'
FactoryGirl.find_definitions

describe Post, "#initialize" do
  context 'valid post name' do

    before(:each) do
      Post.any_instance.stub(:post_exists?) { true }
      Post.any_instance.stub(:read_post_file) { FactoryGirl.create(:post_data) }
      @test_post = Post.new("blog/goodbye_love")
    end

    it 'assigns the name' do
      @test_post.name.should eq("blog/goodbye_love")
    end

    it 'assigns the section' do
      @test_post.section.should eq("blog")
    end

    it 'assigns the basename' do 
      @test_post.basename.should eq("goodbye_love")
    end
  end # end valid post name

  context 'invalid post name' do
     it "fails with a post file that doesn't exist" do
       expect {Post.new("fake/post")}.to raise_error(ArgumentError)
     end

     it 'fails with a post with a file extension' do
       expect {Post.new("fake/post.mdown")}.to raise_error(NameError)
     end

     it "fails with a post missing a forward slash" do
       expect {Post.new("fakepost")}.to raise_error(NameError)
     end
  end # end invalid post name

  context 'parsing valid post file' do
    before(:each) do 
      Post.any_instance.stub(:post_exists?) {true}
      Post.any_instance.stub(:read_post_file) { FactoryGirl.create(:post_data) }

      @test_post = Post.new("rocknroll/cat")
      @test_attributes = FactoryGirl.attributes_for(:post_data)
    end

    it 'has a date' do
      expect(@test_post.metadata["date"]).to eq(DateTime.strptime(@test_attributes[:date], '%m/%d/%Y'))
    end

    it 'has a summary' do
      expect(@test_post.metadata["summary"]).to eq(@test_attributes[:summary])
    end

    it 'has content' do
      expect(@test_post.content).to eq(@test_attributes[:content])
    end

  end # end parsing post file

end # end Post#initialize
