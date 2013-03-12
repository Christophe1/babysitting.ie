class CreateFilmsGenres < ActiveRecord::Migration
  def change
    create_table :films_genres do |t|
      t.belongs_to :film
      t.belongs_to :genre
    end
  end
end
