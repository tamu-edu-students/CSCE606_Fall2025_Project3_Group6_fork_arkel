Feature: Filter and Sort Search Results
  As a user
  I want to filter and sort search results
  So I can find movies more easily

  Background:
    Given I am logged in as a user
    And the TMDb API is available

  Scenario: User filters search results by genre
    Given I have searched for "action"
    When I select "Action" from the genre filter
    And I apply the filter
    Then I should see filtered results
    And only movies with "Action" genre should appear

  Scenario: User filters search results by decade
    Given I have searched for "movie"
    When I select "2010s" from the decade filter
    And I apply the filter
    Then only movies from "2010s" should appear

  Scenario: User applies multiple filters
    Given I have searched for "movie"
    When I select "Action" from the genre filter
    And I select "2010s" from the decade filter
    And I apply the filters
    Then the intersection of filters should be shown

  Scenario: User clears all filters
    Given I have applied genre and decade filters
    When I clear all filters
    And I apply the filter
    Then full search results should return
    And I should see all movies

  Scenario: User sorts results by popularity
    Given I have searched for "movie"
    When I select "Sort by Popularity"
    Then the results should be ordered by popularity
    And the most popular movies should appear first

  Scenario: User sorts results by rating
    Given I have searched for "movie"
    When I select "Sort by Rating"
    Then the results should be ordered by rating
    And the highest rated movies should appear first

  Scenario: User toggles between sort types
    Given I have searched for "movie"
    When I select "Sort by Popularity"
    And I select "Sort by Rating"
    Then the results should be reordered by rating
    And the order should be different from popularity

  Scenario: Sorting empty results shows unchanged empty state
    Given I have no search results
    When I try to sort the results
    Then the empty state should remain unchanged
