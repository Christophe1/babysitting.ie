class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :user_id
      t.integer :author_id
      t.integer :category_id
      t.string  :name, :null => false
      t.string  :phone
      t.text    :comment
      t.timestamps
    end

    add_index :reviews, :user_id
    add_index :reviews, :author_id
    add_index :reviews, :category_id

  end
end
