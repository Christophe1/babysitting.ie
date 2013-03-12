class FilmsController < ApplicationController
  layout 'logged_in'

  before_filter :authenticate_user!
  before_filter :check_if_user_can_search_films
  before_filter :load_genres

  has_scope :by_genre, :type => :array

  def index
    @film_users = apply_scopes(FilmUser.descending.from_facebook_neighbors_and_me(current_user).with_film.with_user).paginate(:page => params[:page])
  end

  def suggestions
    render :json => Film.suggestions(params[:query], current_user.id)
  end

  def duplicate
    @film = FilmUser.find(params[:id])
    @film.duplicate(current_user)
    flash[:notice] = I18n.t("my_films.duplicate_success")
    redirect_to my_films_path
  end

  private

  def check_if_user_can_search_films
    current_user and current_user.can_search_films?
  end

  def load_genres
     @genres = Genre.sorted_by_name.all
   end
end
