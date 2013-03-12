class AddAddressToReview < ActiveRecord::Migration
  def change
    change_table :reviews do |t|
      t.string  :address
      t.decimal :lat, :precision => 12, :scale => 9
      t.decimal :lng, :precision => 12, :scale => 9
    end
  end
end
