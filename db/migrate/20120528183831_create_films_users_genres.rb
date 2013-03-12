class CreateFilmsUsersGenres < ActiveRecord::Migration
  def change
    create_table :films_users_genres do |t|
      t.belongs_to :film_user
      t.belongs_to :genre
    end
  end
end
