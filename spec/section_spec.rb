require 'cloud_crooner'

require_relative 'spec_helper'
require_relative '../starman_error'
require_relative '../section'

describe Section, "#initialize" do
  context 'section exists' do
    before(:each) do
      Section.stub(:exists?) { true }
    end
    
    it 'assigns the name' do
      Dir.stub(:entries) { ["p1-123.mdown", "p2-123.mdown", "p3-123.mdown"] }
      @blog = Section.new("blog")
      expect(@blog.name).to eq("blog")
    end

    it 'assigns the posts' do
      Dir.stub(:entries) { ["p1-123.mdown", "p2-123.mdown", "p3-123.mdown"] }
      @blog = Section.new("blog")
      expect(@blog.posts).to eq(["blog/p1-123.mdown", "blog/p2-123.mdown", "blog/p3-123.mdown"])
    end

    it 'excludes any dotfiles in the posts listing' do
      Dir.stub(:entries) { ["p1-123.mdown", ".badfile", "p2-123.mdown", "p3-123.mdown", ".postfile"] }
      @blog = Section.new("blog")
      expect(@blog.posts).to eq(["blog/p1-123.mdown", "blog/p2-123.mdown", "blog/p3-123.mdown"])
    end
  end # end section exists

  it 'errors when the section does not exist' do
    expect{Section.new("fake_section")}.to raise_error(Starman::SectionNotFound)
  end
end
