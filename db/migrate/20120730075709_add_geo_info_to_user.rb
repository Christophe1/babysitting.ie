class AddGeoInfoToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.decimal :lat, :precision => 12, :scale => 9
      t.decimal :lng, :precision => 12, :scale => 9
    end
  end
end
