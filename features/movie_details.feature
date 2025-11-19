Feature: View Movie Details
  As a user
  I want to view detailed information for a movie
  So I can learn more about it

  Background:
    Given I am on the movies search page
    And the TMDb API is available

  Scenario: View movie details page
    Given I search for "Inception"
    And I see search results
    When I click on "Inception"
    Then I should be on the movie details page
    And I should see the movie poster
    And I should see the movie title "Inception"
    And I should see the movie overview
    And I should see the movie genres
    And I should see the cast information

  Scenario: View movie with missing metadata
    Given I am viewing a movie with missing poster
    When the page loads
    Then I should see a placeholder for the poster
    And I should see the movie title

  Scenario: Load cached movie details
    Given I have previously viewed movie "27205"
    When I visit the movie details page for "27205"
    Then the cached data should load instantly
    And I should see the movie information

  Scenario: Movie not found
    Given the movie with ID "999999" does not exist
    When I visit the movie details page for "999999"
    Then I should see an error message
    And I should see "Movie Not Found"

