require 'cloud_crooner'
require_relative 'spec_helper'
require_relative '../starman_error'
require_relative '../section'
require_relative '../content'

describe Starman::Section, "#initialize" do
  context 'section exists' do
    
    it 'assigns the name' do
      within_construct do |c|
        sample_files(c)
        CloudCrooner.prefix = 'content'
        Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'content'))
        CloudCrooner.manifest.compile('blog/p1.mdown', 'blog/p2.mdown', 'blog/p3.mdown')
        @blog = Starman::Section.new("blog", "blog-proxy-124.json")
        expect(@blog.name).to eq("blog")
      end # construct
    end

    it 'assigns the digest file' do
      within_construct do |c|
        sample_files(c)
        CloudCrooner.prefix = 'content'
        Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'content'))
        CloudCrooner.manifest.compile('blog/p1.mdown', 'blog/p2.mdown', 'blog/p3.mdown')
        @blog = Starman::Section.new("blog", "blog-proxy-124.json")
        expect(@blog.digest_name).to eq("blog-proxy-124.json")
      end # construct
    end

    it 'gathers an array of the compiled post names under the section' do
      within_construct do |c|
        sample_files(c)
        CloudCrooner.prefix = 'content'
        Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'content'))
        CloudCrooner.manifest.compile('blog/p1.mdown', 'blog/p2.mdown', 'blog/p3.mdown')
        @blog = Starman::Section.new("blog", "blog-proxy-124.json")
        expect(@blog.posts).to eq(["blog/p1", "blog/p2", "blog/p3"])
      end #construct
    end

    it 'does not grab posts under the section which have not been compiled' do
      within_construct do |c|
        sample_files(c)
        CloudCrooner.prefix = 'content'
        Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'content'))
        CloudCrooner.manifest.compile('blog/p1.mdown')
        @blog = Starman::Section.new("blog", "blog-proxy-124.json")

        expect(@blog.posts).to eq(["blog/p1"])
      end #construct
    end #it

  end #context section exists

  it 'errors when the section does not exist' do
    expect{Starman::Section.new("fake_section", "doesnotexist.json")}.to raise_error(Starman::SectionNotFound)
  end #it

  it 'errors if the section has posts but none have been compiled' do
    within_construct do |c|
      sample_files(c)
      CloudCrooner.prefix = 'content'
      Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'content'))

      expect{Starman::Section.new("blog", "blog-123.json")}.to raise_error(Starman::SectionEmpty)
    end #construct
  end #it

  after(:each) do
    reload_environment
  end
end
