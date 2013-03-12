module SearchHelper

  def grouped_and_sorted_by_distance(reviews)
    my_area = []
    outside_area = []
    reviews.each do |review|
      distance = current_user.distance_to(review.user)
      # review.distance = distance
      distance <= @kms_range ? (my_area << review) : (outside_area << review)
    end
    return my_area, outside_area
  end

  def grouped_by_owner(my_area_reviews)
    my_reviews = []
    followers_reviews = []
    following_reviews = []
    others_reviews = []

    my_area_reviews.each do |review|
      if current_user.id == review.user_id
        my_reviews << review
      elsif User.followers_for(current_user).pluck(:id).include? review.user_id
        followers_reviews << review
      elsif User.following_by(current_user).pluck(:id).include? review.user_id
        following_reviews << review
      else
        others_reviews << review
      end
    end
    return my_reviews, followers_reviews, following_reviews, others_reviews
  end

end
