# == Schema Information
#
# Table name: category_reviews
#
#  id          :integer(4)      not null, primary key
#  category_id :integer(4)
#  review_id   :integer(4)
#

class CategoryReview < ActiveRecord::Base
  belongs_to :category
  belongs_to :review

  validates :review, :presence => true
  validates :category, :presence => true




end

