require 'cloud_crooner'
require_relative 'spec_helper'
require_relative ('../section')
require_relative ('../starman_error')
require_relative ('../section_proxy')
require_relative ('../content')

describe Starman::SectionProxy do
  it 'finds the posts in the section' do
    within_construct do |c|
      c.file('assets/content/blog/p1.mdown')
      c.file('assets/content/blog/p2.mdown')
      c.file('assets/content/blog/p3.mdown')
      Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'assets/content'))

      proxy = Starman::SectionProxy.new('blog')

      expect(proxy.instance_variable_get(:@files).map { |file| File.basename(file)}).to eq(['p1.mdown', 'p2.mdown', 'p3.mdown'])
    end # construct
  end # it

  it 'deletes the old proxies before creating new ones' do
    within_construct do |c|
      c.file("assets/content/proxies/old-proxy.json")
      c.file("assets/content/blog/normal_data.mdown", FactoryGirl.create(:post_data))
      Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'assets/content'))

      Starman::SectionProxy.create_section_proxies
      expect(File.exists?(File.join(Starman::SectionProxy.proxies_dir, 'old-proxy.json'))).to be_false 
    end #construct
  end

  it 'does not create a proxy if a section is empty' do
    within_construct do |c|
      c.directory("assets/content/empty_dir")
      c.file("assets/content/blog/normal_data.mdown", FactoryGirl.create(:post_data))
      Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'assets/content'))

      expect{ Starman::SectionProxy.create_section_proxies }.to raise_error(Starman::SectionEmpty)
 
    end #construct
  end #it

  it 'creates a proxy object for an existing section' do 
    within_construct do |c|
      c.file("assets/content/blog/normal_data.mdown", FactoryGirl.create(:post_data))
      Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'assets/content'))
      
      Starman::SectionProxy.create_section_proxies
      expect(File.exists?(File.join(Starman::SectionProxy.proxies_dir, 'blog-proxy.json'))).to be_true

    end #construct
  end #it 

end
