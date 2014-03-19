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
      end

      it 'adds a section to the cache' do
        within_construct(keep_on_error: true) do |c|
          CloudCrooner.prefix = 'section'
          section_name = "blog"
          c.file("section/blog/best_post.mdown", FactoryGirl.create(:post_data, :best_post))
          c.file("section/blog/second_best.mdown", FactoryGirl.create(:post_data, :second_best))
          c.file("section/blog/ok_post.mdown", FactoryGirl.create(:post_data, :ok_post))
          Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'section'))
          Starman::SectionProxy.create_section_proxies
          CloudCrooner.manifest.compile('proxies/blog-proxy.json', 'blog/best_post.mdown', 'blog/second_best.mdown', 'blog/ok_post.mdown')

          @section = testapp.new.get_or_add_section_to_cache(section_name)
          expect(@memcached.get(@section.digest_name).posts).to eq(@section.posts)
        end # context
      end # it

      it "adds a section's posts to the cache" do
        within_construct(keep_on_error: true) do |c|
          CloudCrooner.prefix = 'section'
          section_name = "blog"
          c.file("section/blog/best_post.mdown", FactoryGirl.create(:post_data, :best_post))
          c.file("section/blog/second_best.mdown", FactoryGirl.create(:post_data, :second_best))
          c.file("section/blog/ok_post.mdown", FactoryGirl.create(:post_data, :ok_post))
          Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'section'))
          Starman::SectionProxy.create_section_proxies
          CloudCrooner.manifest.compile('proxies/blog-proxy.json', 'blog/best_post.mdown', 'blog/second_best.mdown', 'blog/ok_post.mdown')

          # check to make sure looking for the posts in cache misses
          @get_misses = @memcached.stats[@test_memcached_server]["get_misses"].to_i
          @get_hits= @memcached.stats[@test_memcached_server]["get_hits"].to_i
          ['blog/best_post', 'blog/second_best', 'blog/ok_post'].each do |post_name|
            digest_name = testapp.new.newest_post_digest(post_name)
            expect(@memcached.get(digest_name)).to eq(nil)
          end

          expect(@memcached.stats[@test_memcached_server]["get_misses"].to_i).to eq(@get_misses + 3)
          expect(@memcached.stats[@test_memcached_server]["get_hits"].to_i).to eq(@get_hits)

          @section = testapp.new.get_or_add_section_to_cache(section_name)

          # check to make sure looking for the posts hits
          @get_misses = @memcached.stats[@test_memcached_server]["get_misses"].to_i
          @get_hits= @memcached.stats[@test_memcached_server]["get_hits"].to_i
          ['blog/best_post', 'blog/second_best', 'blog/ok_post'].each do |post_name|
            digest_name = testapp.new.newest_post_digest(post_name)
            expect(@memcached.get(digest_name)).to be_an_instance_of(Starman::Post) 
          end

          expect(@memcached.stats[@test_memcached_server]["get_misses"].to_i).to eq(@get_misses)
          expect(@memcached.stats[@test_memcached_server]["get_hits"].to_i).to eq(@get_hits + 3)

        end # construct 
      end # it

      it 'sorts the section posts by date' do
        within_construct do |c|
          CloudCrooner.prefix = 'section'
          section_name = "blog"
          c.file("section/blog/most_recent.mdown", FactoryGirl.create(:post_data, :most_recent))
          c.file("section/blog/earliest.mdown", FactoryGirl.create(:post_data, :earliest))
          c.file("section/blog/middle.mdown", FactoryGirl.create(:post_data, :middle))
          Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'section'))
          Starman::SectionProxy.create_section_proxies
          CloudCrooner.manifest.compile('proxies/blog-proxy.json', 'blog/most_recent.mdown', 'blog/earliest.mdown', 'blog/middle.mdown')

          section = Starman::Section.new("blog", "blog-proxy-fake.json")
          # posts are unsorted on creation of the section
          expect(section.posts).to eq([testapp.new.newest_post_digest('blog/earliest'), testapp.new.newest_post_digest('blog/middle'), testapp.new.newest_post_digest('blog/most_recent')])

          # posts are sorted after helper is run
          section = testapp.new.get_or_add_section_to_cache(section_name)
          expect(section.posts).to eq([testapp.new.newest_post_digest('blog/most_recent'), testapp.new.newest_post_digest('blog/middle'), testapp.new.newest_post_digest('blog/earliest')])
        end # context
      end # sorts posts

    end # empty cache tests

    context 'the section is in the cache' do
      it 'retrieves the section from the cache' do
        @test_memcached_server = '127.0.0.1:11211'
        @memcached = testapp.new.settings.memcached
        @memcached.flush
        within_construct(keep_on_error: true) do |c|
          CloudCrooner.prefix = 'section'
          section_name = "blog"
          c.file("section/blog/best_post.mdown", FactoryGirl.create(:post_data, :best_post))
          c.file("section/blog/second_best.mdown", FactoryGirl.create(:post_data, :second_best))
          c.file("section/blog/ok_post.mdown", FactoryGirl.create(:post_data, :ok_post))
          Starman::Content.stub(:raw_content_dir).and_return(File.join(c, 'section'))
          Starman::SectionProxy.create_section_proxies
          CloudCrooner.manifest.compile('proxies/blog-proxy.json', 'blog/best_post.mdown', 'blog/second_best.mdown', 'blog/ok_post.mdown')
          
          section = testapp.new.get_or_add_section_to_cache(section_name)

          @get_misses = @memcached.stats[@test_memcached_server]["get_misses"].to_i
          @get_hits= @memcached.stats[@test_memcached_server]["get_hits"].to_i
          @set_count= @memcached.stats[@test_memcached_server]["cmd_set"].to_i

          section2 = testapp.new.get_or_add_section_to_cache(section_name)
          
          expect(@memcached.stats[@test_memcached_server]["get_misses"].to_i).to eq(@get_misses)
          expect(@memcached.stats[@test_memcached_server]["cmd_set"].to_i).to eq(@set_count)
          expect(@memcached.stats[@test_memcached_server]["get_hits"].to_i).to eq(@get_hits +1)

          expect(section2.posts).to eq(section.posts)
        end #construct
      end #it
    end #context

    after(:each) do 
      reload_environment
    end
  end # section helpers
end 
