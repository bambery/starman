require 'factory_girl'

FactoryGirl.define do

  factory :post_data, class: String  do
    skip_create
    
      date "04/11/2013"
      title "A magnificent post!"
      summary "a foo bar baz"
      divider "*-----*-----*-----*"
      content "#Test Post Foo\n\nHere's some content for ya guv!"
      extras nil

      ignore do
        summary_keyword "Summary:"
        date_keyword "Date:"
        title_keyword "Title:"
      end

      trait :no_date_keyword do
        date_keyword nil
        date nil
      end

      trait :no_summary_keyword do
        summary_keyword nil
        summary nil
      end

      trait :date_missing_colon do
        date_keyword "Date"
      end

      trait :no_content do
        content nil
      end

      trait :no_date do
        date nil
      end

      trait :no_summary do
        summary nil
      end

      trait :bad_date do
        date "abcd"
      end
       
      trait :no_title do
        title nil
      end

      trait :extra_metadata do
        extras "in_sky: waiting\nmind: blown"
      end

      trait :extra_whitespace do
        date_keyword "\n\n        Date:       "
        date "        04/11/2013/        "
        summary_keyword "\n\n Summary:     "
        summary "         a foo bar baz     \n"
        content "        \n#Test Post Foo\n\nHere's some content for ya guv! \n\n    "
      end

      trait :no_divider do
        divider nil
      end

      trait :best_post  do
        content { FactoryGirl.create(:content) }
        summary "The best post needs no summary"
        date "01/10/2001"
      end

      trait :second_best do 
        content { FactoryGirl.create(:content, :second_best) }
        summary "Read more about the second best post"
        date "02/20/2012"
      end

      trait :ok_post do
        content { FactoryGirl.create(:content, :only_ok) }
        summary "a post like any other"
        date "04/14/2013"
      end

      trait :earliest do
        date "01/10/2001"
      end

      trait :most_recent do
        date "04/10/2013"
      end

      trait :middle do
        date "03/10/2010"
      end

    initialize_with { new("#{date_keyword} #{date} \n#{title_keyword} #{title} \n#{summary_keyword} #{summary} \n#{extras}\n#{divider}\n\n#{content}\n\n") }
  end

  factory :content, class: String do
    skip_create

    markdown_h1 "#"
    title "Best Post Ever"
    post_entry "This is the entry to a terribly exciting post." 
    
    trait :second_best do
      title "This Post Is Second Best"
      post_entry "Second best is ok, too." 
    end

    trait :only_ok do
      title "This Post Is Only OK."
      post_entry "Well, it's still a post, I guess" 
    end


    initialize_with { new("\n#{markdown_h1}#{title}\n\n#{post_entry}") }

  end

end
