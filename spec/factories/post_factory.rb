require 'factory_girl'

FactoryGirl.define do
  factory :post do
    post_name "blog/foo"
  end

  initialize_with { Post.build_with_name(post_name) }
end
