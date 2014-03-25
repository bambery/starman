module Starman
  module PostHelpers
    def display_date(post)
      post.metadata["date"].strftime("%m-%d-%Y")
    end

  end
end
