class AddRepostFromToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :repost_from, :integer
  end
end
