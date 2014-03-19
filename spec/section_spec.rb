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
        @blog = Starman::Section.new("blog", "blog-proxy-124.json")
        expect(@blog.name).to eq("blog")
      end # construct
    end

    it 'assigns the digest file' do
      within_construct do |c|
        sample_files(c)
        @blog = Starman::Section.new("blog", "blog-proxy-124.json")
        expect(@blog.digest_name).to eq("blog-proxy-124.json")
      end # construct
    end

    it 'assigns the posts' do
      within_construct do |c|
        sample_files(c)
        @blog = Starman::Section.new("blog", "blog-proxy-124.json")
        expect(@blog.posts).to eq(["blog/p1-123.mdown", "blog/p2-123.mdown", "blog/p3-123.mdown"])
      end #construct
    end

    it 'excludes any dotfiles in the posts listing' do
      within_construct do |c|
        sample_files(c)
        c.file('public/assets/blog/.dot_file')
        @blog = Starman::Section.new("blog", "blog-proxy-124.json")
        expect(@blog.posts).to eq(["blog/p1-123.mdown", "blog/p2-123.mdown", "blog/p3-123.mdown"])
      end #construct
    end
  end # end section exists

  it 'errors when the section does not exist' do
    expect{Starman::Section.new("fake_section", "doesnotexist.json")}.to raise_error(Starman::SectionNotFound)
  end

  after(:each) do
    reload_environment
  end
end
