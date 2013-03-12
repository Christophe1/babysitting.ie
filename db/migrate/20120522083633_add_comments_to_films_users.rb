class AddCommentsToFilmsUsers < ActiveRecord::Migration
  def change
    add_column :films_users, :comments, :text
  end
end
