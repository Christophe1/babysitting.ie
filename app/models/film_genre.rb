# == Schema Information
#
# Table name: films_genres
#
#  id       :integer(4)      not null, primary key
#  film_id  :integer(4)
#  genre_id :integer(4)
#

class FilmGenre < ActiveRecord::Base
  self.table_name =  :films_genres

  belongs_to :film
  belongs_to :genre

  validates :film, :presence => true
  validates :genre, :presence => true
end
