Feature: See Similar Movies
  As a user
  I want to see similar movies
  So I can discover related films

  Background:
    Given I am on the movies search page
    And the TMDb API is available

  Scenario: View similar movies section
    Given I am viewing the movie details page for "Inception"
    When I scroll to the similar movies section
    Then I should see recommended titles
    And I should see at least one similar movie

  Scenario: Click on similar movie
    Given I am viewing the movie details page for "Inception"
    And I see similar movies
    When I click on a similar movie
    Then I should be taken to its details page
    And I should see the similar movie's title

  Scenario: TMDb API fails for similar movies
    Given I am viewing the movie details page for "Inception"
    And the TMDb API fails for similar movies
    When the similar movies section loads
    Then I should see an error placeholder
    And I should see an error message

