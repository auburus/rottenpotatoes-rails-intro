class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.get_all_ratings

    @sorting = session.has_key?(:sorting) ? session[:sorting] : nil
    @ratings = session.has_key?(:ratings) ? session[:ratings] : @all_ratings

    if params.has_key?(:sort) and Movie.column_names.include? params[:sort]
      @sorting = params[:sort]
      session[:sorting] = @sorting
    end

    if params.has_key?(:commit)
      @ratings = params.has_key?(:ratings) ? params[:ratings].keys : []
      @ratings = @ratings.select{ |x| @all_ratings.include? x}
      session[:ratings] = @ratings
    end

    # Redirect to the "restful" url
    unless params.has_key?(:sort) and params.has_key?(:commit)
      _ratings = Hash[@ratings.map {|x| ["ratings[#{x}]", 1]}]
      redirect_to({action: 'index', sort: (@sorting.nil? ? "" : @sorting), commit: 'Refresh'}.merge(_ratings))
    end

    @movies = Movie.where(rating: @ratings)
                   .order(@sorting)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end


end
