require_relative './spec_helper'
require_relative '../helpers.rb'
require_relative '../post.rb'
require 'factory_girl'
FactoryGirl.find_definitions

describe Starman do
  subject(:helpers) do
    Class.new do
      include Starman::CachingHelpers
      def settings
        app.settings
      end 
    end
  end


  context 'caching helpers' do
    context 'the cache is empty' do
      before(:each) do
        @test_memcached_server = ENV['TEST_MEMCACHED_SERVER']
        Post.stub(:post_exists?) {true}
        Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data)}
        @test_post = Post.new('foo/bar')

        app.settings.memcached.flush
        @get_misses = app.settings.memcached.stats[@test_memcached_server]["get_misses"].to_i
        @get_hits= app.settings.memcached.stats[@test_memcached_server]["get_hits"].to_i
        @set_count= app.settings.memcached.stats[@test_memcached_server]["cmd_set"].to_i
      end

      it 'adds the post to an empty cache' do
        # double check the post is not in the cache
        @post = helpers.new.get_or_add_post_to_cache(@test_post.name)
        (@get_misses+=1).should eq(app.settings.memcached.stats[@test_memcached_server]["get_misses"].to_i)
        (@set_count+=1).should eq(app.settings.memcached.stats[@test_memcached_server]["cmd_set"].to_i)
      end
    end

  end
end
