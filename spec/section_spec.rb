require_relative 'spec_helper'

describe Section, "#initialize" do
  context 'section exists' do
    before(:each) do
      Section.any_instance.stub(:section_exists?) { true }
    end
    
    it 'assigns the name' do
      Dir.stub(:entries) { ["p1", "p2", "p3"] }
      @blog = Section.new("blog")
      expect(@blog.name).to eq("blog")
    end

    it 'assigns the posts' do
      Dir.stub(:entries) { ["p1", "p2", "p3"] }
      @blog = Section.new("blog")
      expect(@blog.posts).to eq(["blog/p1", "blog/p2", "blog/p3"])
    end

    it 'excludes any dotfiles in the posts listing' do
      Dir.stub(:entries) { ["p1", ".badfile", "p2", "p3", ".postfile"] }
      @blog = Section.new("blog")
      expect(@blog.posts).to eq(["blog/p1", "blog/p2", "blog/p3"])
    end
  end # end section exists

  it 'errors when the section does not exist' do
    expect{Section.new("fake_section")}.to raise_error(Starman::SectionNotFound)
  end
end
