Feature: Watch history logging
  As a signed-in user
  I want to log movies I have watched
  So I can track my viewing history

  Background:
    Given I am logged in as a user

  Scenario: Log a movie with rating and view sorted history
    Given a movie exists with tmdb id "7100"
    When I log the movie as watched with rating "8"
    And I view my watch history sorted by newest
    Then I should see the movie in my watch history

  Scenario: View watch history sorted by name
    Given a movie exists with tmdb id "7102"
    When I log the movie as watched with rating "6"
    And I view my watch history sorted by name ascending
    Then I should see the movie in my watch history

  Scenario: Filter watch history by date range
    Given a movie exists with tmdb id "7103"
    When I log the movie as watched with rating "5"
    And I view my watch history from "2025-12-01" to "2025-12-31"
    Then I should see the movie in my watch history

  Scenario: Invalid watch history date filter is ignored
    When I view my watch history with invalid dates
    Then I should see an empty watch history message

  Scenario: Ensure runtime is fetched when missing
    Given a movie exists with tmdb id "7104" and no runtime
    When I log the movie as watched with rating "6"
    Then the movie runtime should be updated from tmdb
    And I should see the movie in my watch history

  Scenario: Filter watch history by title
    Given a movie exists with tmdb id "7101"
    When I log the movie as watched with rating "7"
    And I search my watch history for "7101"
    Then I should see the movie in my watch history
