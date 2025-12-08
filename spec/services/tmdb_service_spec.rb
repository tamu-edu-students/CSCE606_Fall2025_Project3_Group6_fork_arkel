require "rails_helper"

RSpec.describe TmdbService do
  let(:access_token) { "token" }
  let(:service) do
    allow(ENV).to receive(:fetch).with("TMDB_ACCESS_TOKEN", "").and_return(access_token)
    described_class.new
  end

  let(:success_response) do
    instance_double(Faraday::Response, success?: true, status: 200, body: { "results" => [ { "title" => "Movie" } ], "total_pages" => 1, "total_results" => 1 })
  end

  let(:rate_limited_response) do
    instance_double(Faraday::Response, success?: false, status: 429, body: {})
  end
  let(:failure_response) do
    instance_double(Faraday::Response, success?: false, status: 500, body: {})
  end

  before do
    Rails.cache.clear
  end

  describe "#search_movies" do
    it "returns cached results when present" do
      Rails.cache.write("tmdb_search_query_page_1", { cached: true })

      result = service.search_movies("query", page: 1)

      expect(result).to eq({ cached: true })
    end

    it "returns empty results when query is blank" do
      expect(service.search_movies("")).to eq(results: [], total_pages: 0, total_results: 0)
    end

    it "stores successful responses in cache" do
      allow(service).to receive(:authorized_get).and_return(success_response)

      result = service.search_movies("Query", page: 1)

      expect(result["results"].first["title"]).to eq("Movie")
      expect(Rails.cache.read("tmdb_search_query_page_1")).to eq(success_response.body)
    end

    it "returns rate limit error when 429 and no cache" do
      allow(service).to receive(:authorized_get).and_return(rate_limited_response)

      result = service.search_movies("Query", page: 1)

      expect(result[:error]).to match(/Rate limit/)
    end

    it "returns connection error when Faraday raises" do
      allow(service).to receive(:authorized_get).and_raise(Faraday::TimeoutError)
      result = service.search_movies("Query", page: 1)
      expect(result[:error]).to include("Connection error")
    end

    it "rescues generic errors" do
      allow(service).to receive(:authorized_get).and_raise(StandardError.new("boom"))
      result = service.search_movies("Query", page: 1)
      expect(result[:error]).to eq("An error occurred")
    end

    it "returns API request failed when response not successful" do
      allow(service).to receive(:authorized_get).and_return(failure_response)
      result = service.search_movies("Query", page: 1)
      expect(result[:error]).to eq("API request failed")
    end
  end

  describe "#movie_details" do
    it "returns nil for blank id" do
      expect(service.movie_details(nil)).to be_nil
    end

    it "returns cached data when present" do
      Rails.cache.write("tmdb_movie_1", { "id" => 1 })
      expect(service.movie_details(1)).to eq({ "id" => 1 })
    end

    it "fetches and caches data on success" do
      allow(service).to receive(:authorized_get).and_return(success_response)

      expect(service.movie_details(2)).to eq(success_response.body)
      expect(Rails.cache.read("tmdb_movie_2")).to eq(success_response.body)
    end

    it "returns nil on failure" do
      allow(service).to receive(:authorized_get).and_return(failure_response)
      expect(service.movie_details(3)).to be_nil
    end

    it "rescues exceptions and returns nil" do
      allow(service).to receive(:authorized_get).and_raise(StandardError.new("boom"))
      expect(service.movie_details(4)).to be_nil
    end
  end

  describe "#similar_movies" do
    it "returns empty results when id is blank" do
      expect(service.similar_movies(nil)).to eq(results: [], total_pages: 0)
    end

    it "returns cached data when present" do
      Rails.cache.write("tmdb_similar_5_page_1", { "results" => [] })
      expect(service.similar_movies(5)).to eq({ "results" => [] })
    end

    it "fetches and caches on success" do
      allow(service).to receive(:authorized_get).and_return(success_response)

      expect(service.similar_movies(5)).to eq(success_response.body)
      expect(Rails.cache.read("tmdb_similar_5_page_1")).to eq(success_response.body)
    end

    it "returns error hash on failure" do
      allow(service).to receive(:authorized_get).and_return(failure_response)
      expect(service.similar_movies(5)).to include(:error)
    end

    it "rescues standard errors" do
      allow(service).to receive(:authorized_get).and_raise(StandardError.new("boom"))
      expect(service.similar_movies(5)).to include(:error)
    end
  end

  describe "#trending_movies" do
    it "returns cached data when rate limited" do
      Rails.cache.write("tmdb_trending_week_page_1", { cached: true })
      allow(service).to receive(:authorized_get).and_return(rate_limited_response)

      expect(service.trending_movies).to eq({ cached: true })
    end

    it "fetches and caches on success" do
      allow(service).to receive(:authorized_get).and_return(success_response)

      expect(service.trending_movies(time_window: "day", page: 1)).to eq(success_response.body)
      expect(Rails.cache.read("tmdb_trending_day_page_1")).to eq(success_response.body)
    end

    it "returns fallback on failure" do
      allow(service).to receive(:authorized_get).and_return(failure_response)
      expect(service.trending_movies).to include(:error)
    end

    it "returns fallback when access token missing" do
      allow(ENV).to receive(:fetch).with("TMDB_ACCESS_TOKEN", "").and_return("")
      svc = described_class.new
      expect(svc.trending_movies).to include(:error)
    end

    it "returns cached on connection failure" do
      Rails.cache.write("tmdb_trending_week_page_1", { cached: true })
      allow(service).to receive(:authorized_get).and_raise(Faraday::ConnectionFailed.new("nope"))
      expect(service.trending_movies).to eq({ cached: true })
    end

    it "returns api failure when response not success" do
      allow(service).to receive(:authorized_get).and_return(failure_response)
      expect(service.trending_movies[:error]).to include("Unable to fetch")
    end

    it "returns rate limit error when no cache" do
      allow(service).to receive(:authorized_get).and_return(instance_double(Faraday::Response, success?: false, status: 429, body: {}))
      expect(service.trending_movies[:error]).to match(/Rate limit/)
    end
  end

  describe "#top_rated_movies" do
    it "returns cached data when rate limited" do
      Rails.cache.write("tmdb_top_rated_page_1", { cached: true })
      allow(service).to receive(:authorized_get).and_return(rate_limited_response)

      expect(service.top_rated_movies(page: 1)).to eq({ cached: true })
    end

    it "fetches and caches on success" do
      allow(service).to receive(:authorized_get).and_return(success_response)

      expect(service.top_rated_movies(page: 2)).to eq(success_response.body)
      expect(Rails.cache.read("tmdb_top_rated_page_2")).to eq(success_response.body)
    end

    it "returns fallback on failure" do
      allow(service).to receive(:authorized_get).and_return(failure_response)
      expect(service.top_rated_movies(page: 1)).to include(:error)
    end

    it "returns rate limit fallback with no cache" do
      allow(service).to receive(:authorized_get).and_return(instance_double(Faraday::Response, success?: false, status: 429, body: {}))
      expect(service.top_rated_movies(page: 1)[:error]).to match(/Rate limit/)
    end

    it "returns cached on connection failure" do
      Rails.cache.write("tmdb_top_rated_page_1", { cached: true })
      allow(service).to receive(:authorized_get).and_raise(Faraday::ConnectionFailed.new("fail"))
      expect(service.top_rated_movies(page: 1)).to eq({ cached: true })
    end

    it "handles generic error returning cached or fallback" do
      allow(service).to receive(:authorized_get).and_raise(StandardError.new("boom"))
      expect(service.top_rated_movies(page: 1)).to include(:error)
    end
  end

  describe "#genres" do
    it "returns cached genres when present" do
      Rails.cache.write("tmdb_genres", { "genres" => [ { "id" => 1 } ] })

      expect(service.genres).to eq("genres" => [ { "id" => 1 } ])
    end

    it "normalizes and caches genres on success" do
      allow(service).to receive(:authorized_get).and_return(instance_double(Faraday::Response, success?: true, status: 200, body: { "genres" => [ { "id" => 2 } ] }))

      expect(service.genres).to eq("genres" => [ { "id" => 2 } ])
      expect(Rails.cache.read("tmdb_genres")).to eq("genres" => [ { "id" => 2 } ])
    end

    it "returns empty on failure" do
      allow(service).to receive(:authorized_get).and_return(failure_response)
      expect(service.genres).to eq("genres" => [])
    end

    it "rescues exceptions and returns empty" do
      allow(service).to receive(:authorized_get).and_raise(StandardError.new("boom"))
      expect(service.genres).to eq("genres" => [])
    end
  end

  describe ".poster_url" do
    it "returns nil for blank path" do
      expect(described_class.poster_url(nil)).to be_nil
    end

    it "builds the full URL when present" do
      expect(described_class.poster_url("/abc.jpg")).to eq("#{TmdbService::IMAGE_BASE_URL}/abc.jpg")
    end
  end

  describe "#authorized_get" do
    it "raises when access token missing" do
      allow(ENV).to receive(:fetch).with("TMDB_ACCESS_TOKEN", "").and_return("")
      svc = described_class.new
      expect { svc.send(:authorized_get, "movie/top_rated") }.to raise_error("TMDB_ACCESS_TOKEN is not configured")
    end

    it "sets headers and params on request" do
      req_double = double("req", headers: {}, params: {})
      conn_double = double("conn")
      allow(conn_double).to receive(:build_url).with("movie/top_rated").and_return(double(to_s: "http://example.com"))
      expect(conn_double).to receive(:get).with("movie/top_rated").and_yield(req_double).and_return(success_response)
      allow(Faraday).to receive(:new).and_return(conn_double)

      svc = described_class.new
      svc.send(:authorized_get, "movie/top_rated", params: { page: 2 }, log_context: "page=2")

      expect(req_double.headers["Authorization"]).to start_with("Bearer ")
      expect(req_double.params[:page]).to eq(2)
    end
  end
end
