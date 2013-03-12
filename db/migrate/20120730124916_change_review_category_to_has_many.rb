class ChangeReviewCategoryToHasMany < ActiveRecord::Migration
  def up
    remove_column :reviews, :category_id
  end

  def down
    add_column :reviews, :category_id, :integer
  end

end
