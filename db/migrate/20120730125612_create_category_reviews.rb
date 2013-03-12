class CreateCategoryReviews < ActiveRecord::Migration
  def change
    create_table :category_reviews do |t|
      t.belongs_to :category
      t.belongs_to :review
    end
  end
end
