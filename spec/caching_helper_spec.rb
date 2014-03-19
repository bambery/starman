require_relative './spec_helper'
require_relative '../post'
require_relative '../section'
require_relative '../helpers'
require_relative '../starman_error'
require_relative '../content'
require_relative '../section_proxy'

require 'cloud_crooner'
require 'dalli'

describe Starman do
  subject(:testapp) do
    # fake app for testing memcached helpers 
    Class.new do 
      include Starman::CachingHelpers 
      def settings
        self
      end

      def memcached
        @memcached ||= Dalli::Client.new
      end
    end
  end

  context 'post caching helpers' do
    context 'the cache is empty' do
      before(:each) do
        @test_memcached_server = '127.0.0.1:11211' 
        @memcached = testapp.new.settings.memcached
        @memcached.flush
        CloudCrooner.prefix = 'posts'

        @get_misses = @memcached.stats[@test_memcached_server]["get_misses"].to_i
        @get_hits= @memcached.stats[@test_memcached_server]["get_hits"].to_i
        @set_count= @memcached.stats[@test_memcached_server]["cmd_set"].to_i
      end

      it 'creates a new post' do
        within_construct do |c|
          c.directory('posts')
          c.file("posts/blog/normal_data.mdown", FactoryGirl.create(:post_data))
          CloudCrooner.manifest.compile('blog/normal_data.mdown')

          @post_double = Starman::Post.new(CloudCrooner.sprockets["blog/normal_data.mdown"].digest_path)
          @post = testapp.new.get_or_add_post_to_cache("blog/normal_data")
          @post.should be_an_instance_of(Starman::Post)
          @post.should eq(@post_double)
        end # construct
      end # it

      it 'adds a post to an empty cache' do
        within_construct do |c|
          c.directory('posts')
          c.file("posts/blog/normal_data.mdown", FactoryGirl.create(:post_data))
          CloudCrooner.manifest.compile('blog/normal_data.mdown')

          @post = testapp.new.get_or_add_post_to_cache("blog/normal_data")

        # post was not found in cache
          (@get_misses+=1).should eq(@memcached.stats[@test_memcached_server]["get_misses"].to_i)
        # post was added to cache
          (@set_count+=1).should eq(@memcached.stats[@test_memcached_server]["cmd_set"].to_i)

        # post is now in cache
          @memcached.get(@post.digest_name).should eq(@post)
        end
      end

      it 'errors on post without manifest entry and does not add it to the cache' do
        expect {testapp.new.get_or_add_post_to_cache("fake/post")}.to raise_error(Starman::DigestNotFoundError) 
        # not added to cache
        (@set_count).should eq(@memcached.stats[@test_memcached_server]["cmd_set"].to_i)
      end

      it 'errors on posts with manifest entries but do not exist on file system and does not add them to the cache' do
         within_construct do |c|
          c.directory('posts')
          c.file("posts/not_on_system/post.mdown", FactoryGirl.create(:post_data))
          CloudCrooner.manifest.compile('not_on_system/post.mdown')

          # pretend we can't find the post now
          Starman::Post.stub(:exists?) {false}

          expect {testapp.new.get_or_add_post_to_cache("not_on_system/post")}.to raise_error(Starman::FileNotFoundError) 
          (@set_count).should eq(@memcached.stats[@test_memcached_server]["cmd_set"].to_i)
          (@get_misses+=1).should eq(@memcached.stats[@test_memcached_server]["get_misses"].to_i)
          @memcached.get("fake/post").should be_nil
         end #construct
      end
    end # end post is not in cache

    it 'finds and returns a post in the cache' do
      @test_memcached_server = '127.0.0.1:11211' 
      @memcached = testapp.new.settings.memcached
      @memcached.flush
      CloudCrooner.prefix = 'posts'

      within_construct do |c|
        # create post, add to manifest, add to cache
        c.directory('posts')
        c.file("posts/normal/post.mdown", FactoryGirl.create(:post_data))
        CloudCrooner.manifest.compile('normal/post.mdown')
        @post = testapp.new.get_or_add_post_to_cache("normal/post")
        @get_misses = @memcached.stats[@test_memcached_server]["get_misses"].to_i
        @get_hits= @memcached.stats[@test_memcached_server]["get_hits"].to_i
        @set_count= @memcached.stats[@test_memcached_server]["cmd_set"].to_i

        testapp.new.get_or_add_post_to_cache("normal/post").should eq(@post)
        # set count does not icrease
        @set_count.should eq(@memcached.stats[@test_memcached_server]["cmd_set"].to_i)
        # get hits increases by one
       (@get_hits+1).should eq(@memcached.stats[@test_memcached_server]["get_hits"].to_i)

      end # construct
    end # it  

    after(:each) do 
      reload_environment
    end

  end # post helpers
#end
  context 'section helpers', :section => true do
    context 'the cache is empty' do
      before(:each) do
        @test_memcached_server = '127.0.0.1:11211'
        @memcached = testapp.new.settings.memcached
        @memcached.flush

        @get_misses = @memcached.stats[@test_memcached_server]["get_misses"].to_i
        @get_hits= @memcached.stats[@test_memcached_server]["get_hits"].to_i
        @set_count= @memcached.stats[@test_memcached_server]["cmd_set"].to_i
      end

      it 'adds a section to the cache' do
        within_construct(keep_on_error: true) do |c|
          CloudCrooner.prefix = 'section'
          section_name = "blog"
          c.file("section/blog/best_post.mdown", FactoryGirl.create(:post_data, :best_post))
          c.file("section/blog/second_best.mdown", FactoryGirl.create(:post_data, :best_post))
          c.file("section/blog/ok_post.mdown", FactoryGirl.create(:post_data, :ok_post))
          Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'section'))
          Starman::SectionProxy.create_section_proxies
          CloudCrooner.manifest.compile('proxies/blog-proxy.json', 'blog/best_post.mdown', 'blog/second_best.mdown', 'blog/ok_post.mdown')
          @section = testapp.new.get_or_add_section_to_cache(section_name)
          expect(@memcached.get(@section.digest_name).posts).to eq(@section.posts)
        end # context
      end # it
    end # empty cache
#
#      it 'adds the section's posts to the cache' do
#         etc
#
#      it 'sorts the section posts by date' do
#        @section = "blog"
#        Dir.stub(:entries) {create_and_add_section_posts_to_cache(@section, ["earliest", "most_recent", "middle"])}
#        @section_posts = cachinghelpers.new.get_or_add_section_to_cache(@section)
#        expect(@section_posts).to eq(["blog/most_recent", "blog/middle", "blog/earliest"])
#      end
#
    # this is a dupe to the first test
#      it 'creates a new section' do
#        @section = "blog"
#        Dir.stub(:entries) {create_and_add_section_posts_to_cache(@section, ["best_post", "second_best", "ok_post"])}
#        @section_double = Section.new(@section)
#        @section_posts = cachinghelpers.new.get_or_add_section_to_cache(@section)
#        expect(@section_double.posts - @section_posts).to be_empty 
#      end
#    end # empty cache context
#
#    context 'the section is in the cache' do
#      before(:each) do
#        @test_memcached_server = ENV['TEST_MEMCACHED_SERVER']
#        app.settings.memcached.flush
#
#        @section = "blog"
#        Dir.stub(:entries) {create_and_add_section_posts_to_cache(@section, ["best_post", "second_best", "ok_post"])}
#        @section_posts = cachinghelpers.new.get_or_add_section_to_cache(@section)
#
#        @get_misses = app.settings.memcached.stats[@test_memcached_server]["get_misses"].to_i
#        @get_hits= app.settings.memcached.stats[@test_memcached_server]["get_hits"].to_i
#        @set_count= app.settings.memcached.stats[@test_memcached_server]["cmd_set"].to_i
#
#      end
#    
#      it 'retrieves the section from the cache' do
#        @blog_posts = cachinghelpers.new.get_or_add_section_to_cache("blog")
#        @get_misses.should eq(app.settings.memcached.stats[@test_memcached_server]["get_misses"].to_i)
#        @set_count.should eq(app.settings.memcached.stats[@test_memcached_server]["cmd_set"].to_i)
#        (@get_hits+1).should eq(app.settings.memcached.stats[@test_memcached_server]["get_hits"].to_i)
#      end
#
#    end # end primed cache context
#  end # end section cache helpers
    after(:each) do 
      reload_environment
    end
  end # section helpers
end 
