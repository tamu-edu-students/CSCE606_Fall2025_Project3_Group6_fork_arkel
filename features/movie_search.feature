Feature: Search Movies
  As a user
  I want to search movies by title
  So I can find what I'm looking for

  Background:
    Given I am logged in as a user
    And the TMDb API is available

  Scenario: User searches for a movie successfully
    Given I am on the movies search page
    When I enter "Inception" in the search field
    And I submit the search
    Then I should see search results
    And I should see "Inception" in the results

  Scenario: User submits empty search query
    Given I am on the movies search page
    When I enter "" in the search field
    And I submit the search
    Then I should see a prompt to type something

  Scenario: Cached results are displayed when TMDb rate limit occurs
    Given I have previously searched for "Inception"
    And the TMDb API rate limit is exceeded
    When I enter "Inception" in the search field
    And I submit the search
    Then I should see cached results
