class TmdbService
  BASE_URL = "https://api.themoviedb.org/3"
  IMAGE_BASE_URL = "https://image.tmdb.org/t/p/w500"

  def initialize
    @access_token = ENV.fetch("TMDB_ACCESS_TOKEN", "")
    @conn = Faraday.new(url: BASE_URL) do |f|
      f.request :json
      f.response :json
      f.adapter Faraday.default_adapter
    end
  end

  def search_movies(query, page: 1)
    return { results: [], total_pages: 0, total_results: 0 } if query.blank?

    cache_key = "tmdb_search_#{query.downcase}_page_#{page}"
    cached = Rails.cache.read(cache_key)

    return cached if cached.present?

    begin
      response = authorized_get(
        "search/movie",
        params: { query: query, page: page },
        log_context: "q='#{query}' page=#{page}"
      )

      if response.status == 429
        # Rate limit exceeded - return cached results if available
        stale_cache = Rails.cache.read(cache_key)
        return stale_cache if stale_cache.present?

        return {
          results: [],
          total_pages: 0,
          total_results: 0,
          error: "Rate limit exceeded. Please try again later."
        }
      end

      if response.success?
        data = response.body
        Rails.cache.write(cache_key, data, expires_in: 1.hour)
        data
      else
        { results: [], total_pages: 0, total_results: 0, error: "API request failed" }
      end
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed
      # Return cached results if available, even if expired
      stale_cache = Rails.cache.read(cache_key)
      return stale_cache if stale_cache.present?

      { results: [], total_pages: 0, total_results: 0, error: "Connection error. Please try again later." }
    rescue StandardError => e
      { results: [], total_pages: 0, total_results: 0, error: "An error occurred" }
    end
  end

  def movie_details(tmdb_id)
    return nil if tmdb_id.blank?

    cache_key = "tmdb_movie_#{tmdb_id}"
    cached = Rails.cache.read(cache_key)

    return cached if cached.present?

    begin
      response = authorized_get(
        "movie/#{tmdb_id}",
        params: { append_to_response: "credits,videos" }
      )

      if response.success?
        data = response.body
        Rails.cache.write(cache_key, data, expires_in: 24.hours)
        data
      else
        nil
      end
    rescue StandardError => e
      nil
    end
  end

  def similar_movies(tmdb_id, page: 1)
    return { results: [], total_pages: 0 } if tmdb_id.blank?

    cache_key = "tmdb_similar_#{tmdb_id}_page_#{page}"
    cached = Rails.cache.read(cache_key)

    return cached if cached.present?

    begin
      response = authorized_get(
        "movie/#{tmdb_id}/similar",
        params: { page: page },
        log_context: "page=#{page}"
      )

      if response.success?
        data = response.body
        Rails.cache.write(cache_key, data, expires_in: 24.hours)
        data
      else
        { results: [], total_pages: 0, error: "API request failed" }
      end
    rescue StandardError => e
      { results: [], total_pages: 0, error: "An error occurred" }
    end
  end

  def trending_movies(time_window: "week", page: 1)
    cache_key = "tmdb_trending_#{time_window}_page_#{page}"
    cached = Rails.cache.read(cache_key)

    begin
      response = authorized_get(
        "trending/movie/#{time_window}",
        params: { page: page },
        log_context: "time_window=#{time_window} page=#{page}"
      )

      if response.status == 429
        return cached if cached.present?
        return { results: [], total_pages: 0, error: "Rate limit exceeded. Please try again later." }
      end

      if response.success?
        data = response.body
        Rails.cache.write(cache_key, data, expires_in: 2.hours)
        data
      else
        cached.presence || { results: [], total_pages: 0, error: "Unable to fetch trending movies" }
      end
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed
      cached.presence || { results: [], total_pages: 0, error: "Connection error while fetching trending movies" }
    rescue StandardError
      cached.presence || { results: [], total_pages: 0, error: "An error occurred while fetching trending movies" }
    end
  end

  def top_rated_movies(page: 1)
    cache_key = "tmdb_top_rated_page_#{page}"
    cached = Rails.cache.read(cache_key)

    begin
      response = authorized_get(
        "movie/top_rated",
        params: { page: page },
        log_context: "page=#{page}"
      )

      if response.status == 429
        return cached if cached.present?
        return { results: [], total_pages: 0, error: "Rate limit exceeded. Please try again later." }
      end

      if response.success?
        data = response.body
        Rails.cache.write(cache_key, data, expires_in: 4.hours)
        data
      else
        cached.presence || { results: [], total_pages: 0, error: "Unable to fetch top rated movies" }
      end
    rescue Faraday::TimeoutError, Faraday::ConnectionFailed
      cached.presence || { results: [], total_pages: 0, error: "Connection error while fetching top rated movies" }
    rescue StandardError
      cached.presence || { results: [], total_pages: 0, error: "An error occurred while fetching top rated movies" }
    end
  end

  def genres
    cache_key = "tmdb_genres"
    cached = Rails.cache.read(cache_key)

    return cached if cached.present?

    begin
      response = authorized_get("genre/movie/list")

      if response.success?
        data = response.body
        # Ensure data is a hash with genres key
        data = { "genres" => [] } unless data.is_a?(Hash)
        data = { "genres" => data } unless data.key?("genres") || data.key?(:genres)
        # Normalize to string keys
        data = { "genres" => data["genres"] || data[:genres] || [] }
        Rails.cache.write(cache_key, data, expires_in: 7.days)
        data
      else
        { "genres" => [] }
      end
    rescue StandardError => e
      { "genres" => [] }
    end
  end

  # Returns TMDb poster URL if poster_path is present, nil otherwise
  # Note: This method returns nil for blank values - callers should use helper methods
  # that provide fallback to placeholder (e.g., Movie#poster_url or ApplicationHelper#poster_url_for)
  def self.poster_url(poster_path)
    return nil if poster_path.blank?
    "#{IMAGE_BASE_URL}#{poster_path}"
  end

  private

  def authorized_get(path, params: {}, log_context: nil)
    if @access_token.blank?
      raise "TMDB_ACCESS_TOKEN is not configured"
    end

    url = @conn.build_url(path).to_s
    headers = {
      "Authorization" => "Bearer #{@access_token}",
      "Accept" => "application/json"
    }

    response = @conn.get(path) do |req|
      headers.each { |k, v| req.headers[k] = v }
      params.each { |k, v| req.params[k] = v }
    end

    response
  end
end
