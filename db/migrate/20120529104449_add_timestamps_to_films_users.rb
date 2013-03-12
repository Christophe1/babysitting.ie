class AddTimestampsToFilmsUsers < ActiveRecord::Migration
  def change
    add_column :films_users, :created_at, :timestamp
    add_column :films_users, :updated_at, :timestamp
  end
end
