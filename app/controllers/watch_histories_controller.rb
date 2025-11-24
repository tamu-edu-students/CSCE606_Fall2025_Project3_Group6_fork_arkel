class WatchHistoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @watch_history = current_user.watch_history || current_user.create_watch_history
    @watch_logs = @watch_history.watch_logs.includes(:movie).order(watched_on: :desc)
  end

  def create
    movie = Movie.find_by(tmdb_id: params[:movie_id]) || Movie.find_by(id: params[:movie_id])

    unless movie
      # try to create the movie record if a TMDB id was provided by the client
      # if not found we redirect back with error
      redirect_back fallback_location: root_path, alert: "Movie not found" and return
    end

    watched_on = params[:watched_on].presence || Date.current

    watch_history = current_user.watch_history || current_user.create_watch_history

    @watch_log = watch_history.watch_logs.new(movie: movie, watched_on: watched_on)

    if @watch_log.save
      redirect_back fallback_location: movie_path(movie), notice: "Logged as watched on #{watched_on}"
    else
      redirect_back fallback_location: movie_path(movie), alert: @watch_log.errors.full_messages.to_sentence
    end
  end

  def destroy
    watch_history = current_user.watch_history
    @watch_log = watch_history&.watch_logs&.find_by(id: params[:id])
    if @watch_log
      @watch_log.destroy
      redirect_to watch_histories_path, notice: "Removed from watch history"
    else
      redirect_to watch_histories_path, alert: "Watch history entry not found"
    end
  end
end
