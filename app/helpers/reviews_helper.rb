module ReviewsHelper

  def review_block(review, options = {})
    options = {:review => review, :add_to_my_list => false}.merge(options)
    options[:edit_enabled]  ||= review.user == current_user
    render 'reviews/review', options
  end

end
