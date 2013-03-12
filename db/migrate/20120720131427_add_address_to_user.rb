class AddAddressToUser < ActiveRecord::Migration

  def change
    add_column :users, :address, :text, :limit => 1024
  end

end
