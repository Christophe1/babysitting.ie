class CreateFriendRelations < ActiveRecord::Migration
  def change
    create_table :friend_relations do |t|
      t.string :provider
      t.integer :source_user_id, :limit => 8
      t.integer :target_user_id, :limit => 8
    end
  end
end
