require 'factory_girl'

FactoryGirl.define do
#  factory :post do
#
#    factory :properly_formatted_post do
#      post_name "blog/goodbye_love"
#    end
#
#    initialize_with { new(post_name) }
#  
#  end

  factory :post_data, class: String  do
    skip_create
    
      date "04/11/2012"
      summary "a foo bar baz"
      delimiter "*-----*-----*"
      content "#Test Post Foo\n\nHere's some content for ya guv!"

    initialize_with { new("Date: #{date} \nSummary: #{summary} \n\n#{delimiter}\n\n#{content}\n\n") }
  end


end
