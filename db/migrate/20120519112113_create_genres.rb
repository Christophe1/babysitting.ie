class CreateGenres < ActiveRecord::Migration
  def change
    create_table :genres do |t|
      t.string :name
      t.timestamps
    end
    add_index :genres, [:name], :name => 'idx_on_name', :unique => true
  end
end
