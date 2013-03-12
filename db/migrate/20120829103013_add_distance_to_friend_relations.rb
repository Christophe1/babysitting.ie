class AddDistanceToFriendRelations < ActiveRecord::Migration
  def change
    add_column :friend_relations, :distance, :float, :null => false, :default => User::FAR_AWAY
  end
end
