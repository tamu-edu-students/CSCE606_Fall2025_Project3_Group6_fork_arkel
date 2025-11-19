Feature: Search Movies
  As a user
  I want to search movies by title
  So I can find what I'm looking for

  Background:
    Given I am on the movies search page
    And the TMDb API is available

  Scenario: Search for a movie with valid query
    Given I enter "Inception" in the search field
    When I submit the search
    Then I should see search results
    And I should see "Inception" in the results

  Scenario: Search with empty query
    Given I enter "" in the search field
    When I submit the search
    Then I should see a prompt to type something
    And I should not see any movie results

  Scenario: Search results are cached
    Given I search for "Inception"
    And I see search results
    When I search for "Inception" again
    Then the results should load from cache

  Scenario: Handle rate limit with cached results
    Given I have previously searched for "Inception"
    And the TMDb API rate limit is exceeded
    When I search for "Inception"
    Then I should see cached results
    And I should see a rate limit message

