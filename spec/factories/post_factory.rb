require 'factory_girl'

FactoryGirl.define do
  factory :post do

    factory :properly_formatted_post do
      post_name "blog/goodbye_love"
    end

    initialize_with { new(post_name) }
  
  end

  factory :post_data, class: String  do
    skip_create

    ignore do
      file_data "Date: 04/11/2013 \nSummary: A foo bar baz \n\n*-----*-----*\n\n#Test Post Foo\n\nHere's some content for ya guv!\n\n"
    end

    initialize_with { new("#{file_data}") }

  end


end
