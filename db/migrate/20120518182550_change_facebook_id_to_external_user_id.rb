class ChangeFacebookIdToExternalUserId < ActiveRecord::Migration
  def change
    rename_column :users, :facebook_id, :external_user_id
    add_index :users, [:provider, :external_user_id], :name => 'idx_on_provider_and_external_user_id'
  end
end
