class CopyFilmGenres < ActiveRecord::Migration
  def up
    FilmUser.with_film.all.each do |film_user|
      film_user.genres = film_user.film.genres
      film_user.save
    end
  end

  def down
  end
end
