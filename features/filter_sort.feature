Feature: Filter and Sort Search Results
  As a user
  I want to filter and sort search results
  So I can find movies more easily

  Background:
    Given I am on the movies search page
    And the TMDb API is available
    And I have searched for "movie"

  Scenario: Filter by genre
    Given I see search results
    When I select "Action" from the genre filter
    And I apply the filter
    Then only movies with "Action" genre should appear
    And I should see filtered results

  Scenario: Filter by decade
    Given I see search results
    When I select "2010s" from the decade filter
    And I apply the filter
    Then only movies from 2010s should appear
    And I should see filtered results

  Scenario: Apply multiple filters
    Given I see search results
    When I select "Action" from the genre filter
    And I select "2010s" from the decade filter
    And I apply the filters
    Then only Action movies from 2010s should appear
    And the intersection of filters should be shown

  Scenario: Clear all filters
    Given I have applied genre and decade filters
    And I see filtered results
    When I clear all filters
    And I refresh the page
    Then full search results should return
    And I should see all movies

  Scenario: Sort by popularity
    Given I see search results
    When I select "Sort by Popularity"
    Then the results should be ordered by popularity
    And the most popular movies should appear first

  Scenario: Sort by rating
    Given I see search results
    When I select "Sort by Rating"
    Then the results should be ordered by rating
    And the highest rated movies should appear first

  Scenario: Sort by release date
    Given I see search results
    When I select "Sort by Release Date"
    Then the results should be ordered by release date
    And the newest movies should appear first

  Scenario: Toggle between sort types
    Given I see search results
    When I select "Sort by Popularity"
    Then the results should be ordered by popularity
    When I select "Sort by Rating"
    Then the results should be reordered by rating
    And the order should be different from popularity

  Scenario: Sort with no results
    Given I have no search results
    When I try to sort the results
    Then the empty state should remain unchanged
    And I should see "No movies found"

