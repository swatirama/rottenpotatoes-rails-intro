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
    @all_ratings = Movie.all_ratings
    @redirect = 0

    logger.debug(session.inspect)

    if params[:sort_by]
	@sort_by = params[:sort_by]
	session[:sort_by] = params[:sort_by]
    elsif session[:sort_by]
	@sort_by = session[:sort_by]
	@redirect = true
    else
	@sort_by = nil
    end

    if params[:commit] == "Refresh" and params[:sort_by] == nil
	@ratings = nil
	session[:ratings] = nil
    elsif params[:ratings]
	@ratings = params[:ratings]
	session[:ratings] = params[:ratings]
    elsif session[:ratings]
	@ratings = session[:ratings]
	@redirect = true
    else
	@ratings = nil
    end

    if @redirect
	flash.keep
	redirect_to movies_path :sort_by=>@sort_by, :ratings=>@ratings
    end

    #@sort_by = params[:sort_by]
    #@ratings = params[:ratings]
    # @movies = Movie.order(params[:sort_by])
    
    if @ratings and @sort_by
	@movies = Movie.where(:rating => @ratings.keys).order(@sort_by)
    elsif @ratings
	@movies = Movie.where(:rating => @ratings.keys)
    elsif @sort_by
	@movies = Movie.order(@sort_by)
    else
	@movies = Movie.all
    end
    if !@ratings
	@ratings = Hash.new
    end
    #@movies = Movie.all
    #if params[:ratings]
    #    @movies = Movie.where(:rating => params[:ratings].keys).order(params[:sort_by])
    #end
    #@sort_column = params[:sort_by]
    #@all_ratings = Movie.all_ratings
    #@set_ratings = params[:ratings]
    #if !@set_ratings
    #    @set_ratings = Hash.new
    #end
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
