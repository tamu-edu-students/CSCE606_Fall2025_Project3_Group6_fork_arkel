Feature: View Movie Details
  As a user
  I want to view detailed information for a movie
  So I can learn more about it

  Background:
    Given the TMDb API is available
    And I am logged in as a user

  Scenario: View movie details successfully
    Given I search for "Inception"
    When I click on "Inception"
    Then I should be on the movie details page
    And I should see the movie title "Inception"
    And I should see the movie poster
    And I should see the movie overview
    And I should see the movie genres

  Scenario: View movie with missing poster
    Given I am viewing a movie with missing poster
    Then I should see a placeholder for the poster

  Scenario: Load movie from cache
    Given I have previously viewed movie "27205"
    When I visit the movie details page for "27205"
    Then the cached data should load instantly
    And I should see the movie information

  Scenario: Handle movie not found
    Given the movie with ID "999999" does not exist
    When I visit the movie details page for "999999"
    Then I should see an error message
