Feature: See Similar Movies
  As a user
  I want to see similar movies
  So I can discover related films

  Background:
    Given I am logged in as a user
    And the TMDb API is available

  Scenario: User sees similar movies on movie details page
    Given I am viewing the movie details page for "Inception"
    When I scroll to the similar movies section
    Then I should see recommended titles
    And I should see at least one similar movie

  Scenario: User clicks on a similar movie
    Given I am viewing the movie details page for "Inception"
    And I see similar movies
    When I click on a similar movie
    Then I should be taken to its details page
    And I should see the similar movie's title

  Scenario: Error placeholder shown when TMDb API fails
    Given I am viewing the movie details page for "Inception"
    And the TMDb API fails for similar movies
    When I scroll to the similar movies section
    Then I should see an error placeholder
