require_relative './spec_helper'
require_relative '../section.rb'

describe Starman do
  subject(:cachinghelpers) do
    Class.new do
      include Starman::CachingHelpers
      def settings
        app.settings
      end 
    end
  end


  context 'post caching helpers' do
    context 'the cache is empty' do
      before(:each) do
        @test_memcached_server = ENV['TEST_MEMCACHED_SERVER']

        app.settings.memcached.flush
        @get_misses = app.settings.memcached.stats[@test_memcached_server]["get_misses"].to_i
        @get_hits= app.settings.memcached.stats[@test_memcached_server]["get_hits"].to_i
        @set_count= app.settings.memcached.stats[@test_memcached_server]["cmd_set"].to_i
      end

      it 'creates a new post' do
        Post.stub(:post_exists?) {true}
        Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data)}

        @post_double = Post.new("real/post")
        @post = cachinghelpers.new.get_or_add_post_to_cache("real/post")
        @post.should be_an_instance_of(Post)
        @post.should eq(@post_double)
      end

      it 'adds a post to an empty cache' do
        Post.stub(:post_exists?) {true}
        Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data)}

        @post = cachinghelpers.new.get_or_add_post_to_cache("real/post")

        # post was not found in cache
        (@get_misses+=1).should eq(app.settings.memcached.stats[@test_memcached_server]["get_misses"].to_i)
        # post was added to cache
        (@set_count+=1).should eq(app.settings.memcached.stats[@test_memcached_server]["cmd_set"].to_i)

        # post is now in cache
        app.settings.memcached.get(@post.name).should eq(@post)
      end

      it 'errors on posts that do not exist and does not add them to the cache' do
        expect {cachinghelpers.new.get_or_add_post_to_cache("fake/post")}.to raise_error(Starman::FileNotFoundError) 
        # not added to cache
        (@set_count).should eq(app.settings.memcached.stats[@test_memcached_server]["cmd_set"].to_i)
        (@get_misses+=1).should eq(app.settings.memcached.stats[@test_memcached_server]["get_misses"].to_i)
        app.settings.memcached.get("fake/post").should be_nil
      end
    end # end post is not in cache

    context ' the post is in the cache' do
      before(:each) do
        @test_memcached_server = ENV['TEST_MEMCACHED_SERVER']
        app.settings.memcached.flush
        Post.stub(:post_exists?) {true}
        Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data)}
        @post = cachinghelpers.new.get_or_add_post_to_cache("real/post")

        @get_misses = app.settings.memcached.stats[@test_memcached_server]["get_misses"].to_i
        @get_hits= app.settings.memcached.stats[@test_memcached_server]["get_hits"].to_i
        @set_count= app.settings.memcached.stats[@test_memcached_server]["cmd_set"].to_i
      end

      it 'finds and returns a cached post' do
        cachinghelpers.new.get_or_add_post_to_cache(@post.name).should eq(@post)
        # set count does not icrease
        @set_count.should eq(app.settings.memcached.stats[@test_memcached_server]["cmd_set"].to_i)
        # get hits increases by one
        (@get_hits+1).should eq(app.settings.memcached.stats[@test_memcached_server]["get_hits"].to_i)
      end

    end # end context

    context 'section helpers', :section => true do
      context 'the cache is empty' do
        before(:each) do
          @test_memcached_server = ENV['TEST_MEMCACHED_SERVER']

          app.settings.memcached.flush
          @get_misses = app.settings.memcached.stats[@test_memcached_server]["get_misses"].to_i
          @get_hits= app.settings.memcached.stats[@test_memcached_server]["get_hits"].to_i
          @set_count= app.settings.memcached.stats[@test_memcached_server]["cmd_set"].to_i

          Section.any_instance.stub(:find_posts) {FactoryGirl.create(:section_posts, :blog)}
        end

        it 'adds a section to the cache' do
          @section_posts = cachinghelpers.new.get_or_add_section_to_cache("blog")
          expect(app.settings.memcached.get("blog")).to eq(@section_posts)
          #check counts
        end

        it 'sorts the section posts by date' do
          @sorted_posts = FactoryGirl.create(:section_posts, :blog, :sorted)
          @section_posts = cachinghelpers.new.get_or_add_section_to_cache("blog")
          expect(@sorted_posts).to eq(@sorted_posts)
        end

        it 'creates a new section' do
          @section_double = Section.new("blog")
          @section_posts = cachinghelpers.new.get_or_add_section_to_cache("blog")
          expect(@section_double.posts - @section_posts).to be_empty 
        end

      end

  #    it 'ignores filenames beginning with a period (such as swp)', :section => true do
        #stub dir.entries and then do a new section and check for .swp files
  #    end
    end
  end
end
