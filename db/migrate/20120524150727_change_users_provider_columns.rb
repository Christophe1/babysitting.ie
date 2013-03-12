class ChangeUsersProviderColumns < ActiveRecord::Migration
  def up
    remove_index :users, :name => 'idx_on_provider_and_external_user_id'
    change_column :users, :provider, :string, :limit => 20
    change_column :users, :external_user_id, :integer, :limit => 8
    add_index :users, [:provider, :external_user_id], :name => 'idx_on_provider_and_external_user_id', :unique => true
  end

  def down
    remove_index :users, :name => 'idx_on_provider_and_external_user_id'
    change_column :users, :provider, :string
    change_column :users, :external_user_id, :string
    add_index :users, [:provider, :external_user_id], :name => 'idx_on_provider_and_external_user_id'
  end
end
