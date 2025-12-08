Feature: List items management
  As a signed-in user
  I want to add and remove movies from my lists
  So I can curate collections

  Background:
    Given I am logged in as a user

  Scenario: Add movie to own list
    Given I have a personal list and movie
    When I add the movie to my list
    Then I should see a list item success notice

  Scenario: Add movie with missing list shows alert
    Given I have a movie for list items
    When I add the movie to a nonexistent list
    Then I should see a list item alert

  Scenario: Add movie with missing movie shows alert
    Given I have a personal list and movie
    When I add an unknown movie to my list
    Then I should see a list item alert

  Scenario: Remove movie from own list
    Given I have a personal list item
    When I remove the list item
    Then I should see a list item removed notice

  Scenario: Cannot remove someone else's list item
    Given another user has a list item
    When I attempt to remove their list item
    Then I should see a not authorized list item alert
