require 'spec_helper'

describe PostReleaseHooks do
  it 'does nothing when adding a new section' do
    #check memcached hit counts and verify nothing changes
  end
  it 'expires the section cache when adding a new post' do
    app.settings.memcached.get(post).should be_nil
  end
  it 'expires the post cache when modifying an existing post' do
  end

  context 'deleting an existing post' do
    it 'expires the post cache' do
    end

    it 'expires the section cache' do
    end
  end

end
