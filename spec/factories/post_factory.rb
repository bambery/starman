require 'factory_girl'

FactoryGirl.define do
  factory :post do
    post_name "blog/foo"
  end

  initialize_with { new(post_name) }
end
