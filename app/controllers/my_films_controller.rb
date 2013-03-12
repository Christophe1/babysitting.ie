class MyFilmsController < ApplicationController
  layout 'logged_in'

  inherit_resources
  defaults :resource_class => FilmUser, :collection_name => 'my_films', :instance_name => 'my_film'
  before_filter :authenticate_user!
  before_filter :load_genres

  def create
    @my_film = build_resource
    options = { :location => collection_path }
    if create_resource(@my_film) and current_user.have_only_one_film?
      flash[:notice] = I18n.t("my_films.first_film_success", :user => current_user.first_name)
      options[:location] = films_path
    end

    respond_with(@my_film, options)
  end

  def update
    update! { collection_path }
  end

  protected

  # Working with current user films.
  #
  def end_of_association_chain
    current_user.film_users
  end

  # Adds pagination and ordering to collection.
  #
  def collection
    @my_films ||= end_of_association_chain.descending.paginate(:page => params[:page])
  end

  # Prevents creation of films with duplicating names.
  #
  def resource_params
    all_params = super
    attributes = all_params.first
    if film_attributes = attributes[:film_attributes]
      if film = Film.find_by_name(film_attributes[:name])
        attributes[:film_id] = film.id
        attributes.delete(:film_attributes)
      else
        film_attributes.delete(:id)
      end
    else
      attributes[:film_attributes] = {}
    end
    all_params
  end

  private

  def load_genres
    @genres = Genre.sorted_by_name.all
  end
end
