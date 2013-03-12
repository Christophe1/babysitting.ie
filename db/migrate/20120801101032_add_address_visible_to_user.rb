class AddAddressVisibleToUser < ActiveRecord::Migration
  def change
    add_column :users, :address_visible, :boolean, :null => false, :default => false
  end
end
