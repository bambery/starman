require_relative './spec_helper'

describe MemcachedHelpers do
  context 'the cache is empty' do
    before(:each) do
      Post.any_instance.stub(:post_exists?) {true}
      Post.any_instance.stub(:read_post_file) {FactoryGirl.create(:post_data)}
      @test_post = Post.new('foo/bar')

      app.settings.memcached.flush
      @get_misses = app.settings.memcached.stats[test_memcached_server]["get_misses"].to_i
      @get_hits= app.settings.memcached.stats[test_memcached_server]["get_hits"].to_i
      @set_count= app.settings.memcached.stats[test_memcached_server]["cmd_set"].to_i
    end

    it 'adds the post to an empty cache' do
      # double check the post is not in the cache
      app.settings.memcached.get(@test_post).should be_nil
      (@get_misses+=1).should eq(TestFileHelpers.memcached_get_misses_count)
    end

  end
end
