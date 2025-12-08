Feature: Watchlist items controller edge cases
  As a signed-in user
  I want to handle watchlist add/remove edge cases
  So I get clear feedback

  Background:
    Given I am logged in as a user

  Scenario: Adding a nonexistent movie shows an alert and redirects
    When I try to add an unknown movie to my watchlist
    Then I should see a watchlist alert

  Scenario: Adding the same movie twice shows a duplicate notice
    Given a movie exists with tmdb id "8001"
    When I add the movie to my watchlist
    And I add the movie to my watchlist
    Then I should see a duplicate watchlist notice
