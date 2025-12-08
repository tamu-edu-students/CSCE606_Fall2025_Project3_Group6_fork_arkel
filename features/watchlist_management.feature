Feature: Watchlist management
  As a signed-in user
  I want to manage my watchlist
  So I can track movies to watch

  Background:
    Given I am logged in as a user

  Scenario: Add and remove a movie from watchlist
    Given a movie exists with tmdb id "7001"
    When I add the movie to my watchlist
    Then I should see the movie in my watchlist
    When I remove the movie from my watchlist
    Then I should not see the movie in my watchlist

  Scenario: Restore a removed movie
    Given a movie exists with tmdb id "7002"
    And I add the movie to my watchlist
    And I remove the movie from my watchlist
    When I restore the movie to my watchlist
    Then I should see the movie in my watchlist

  Scenario: Adding the same movie twice does not duplicate
    Given a movie exists with tmdb id "7003"
    When I add the movie to my watchlist
    And I add the movie to my watchlist
    Then I should only see the movie once in my watchlist
