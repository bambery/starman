require 'factory_girl'

FactoryGirl.define do

  factory :post_data, class: String  do
    skip_create
    
      date "04/11/2013"
      summary "a foo bar baz"
      divider "*-----*-----*"
      content "#Test Post Foo\n\nHere's some content for ya guv!"
      extras nil

      ignore do
        summary_keyword "Summary:"
        date_keyword "Date:"
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

    initialize_with { new("#{date_keyword} #{date} \n#{summary_keyword} #{summary} \n#{extras}\n#{divider}\n\n#{content}\n\n") }
  end


end
