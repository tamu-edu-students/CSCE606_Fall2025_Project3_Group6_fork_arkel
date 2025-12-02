Feature: See Similar Movies
  As a user
  I want to see similar movies
  So I can discover related films

  Background:
    Given the TMDb API is available
    And I am logged in as a user

  Scenario: View similar movies successfully
    Given I am viewing the movie details page for "Inception"
    When I scroll to the similar movies section
    Then I should see recommended titles

  Scenario: Click on similar movie
    Given I am viewing the movie details page for "Inception"
    And I see similar movies
    When I click on a similar movie
    Then I should be taken to its details page
    And I should see the similar movie's title

  Scenario: Handle API failure for similar movies
    Given I am viewing the movie details page for "Inception"
    And the TMDb API fails for similar movies
    When I scroll to the similar movies section
    Then I should see an error placeholder
