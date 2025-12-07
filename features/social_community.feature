Feature: Social & Community
  As a user
  I want to interact with other users and create movie lists
  So I can build a community around movies

  Background:
    Given I am logged in as a user

  Scenario: User follows another user
    Given there is a user named "alice"
    When I visit "alice"'s profile
    And I click "Follow"
    Then "alice" should be added to my following list
    And "alice" should receive a notification

  Scenario: User unfollows another user
    Given I am following "alice"
    When I visit "alice"'s profile
    And I click "Unfollow"
    Then "alice" should be removed from my following list

  Scenario: User cannot follow themselves
    Given I am on my own profile
    When I try to follow myself
    Then I should see an error message
    And I should not be following myself

  Scenario: User views activity feed from followed users
    Given I am following "alice"
    And "alice" has logged a movie
    When I visit my activity feed
    Then I should see "alice"'s activity in chronological order

  Scenario: User sees empty activity feed
    Given I am following "alice"
    And "alice" has no activity
    When I visit my activity feed
    Then I should see an empty state message

  Scenario: New activity appears in feed
    Given I am following "alice"
    And I visit my activity feed
    When "alice" logs a new movie
    And I refresh the feed
    Then the new activity should appear at the top

  Scenario: User creates a movie list
    Given I am on the lists page
    When I click "Create New List"
    And I enter "My Favorite Movies" as the list name
    And I enter "A collection of my favorite films" as the description
    And I set the list to public
    And I save the list
    Then the list should appear on my profile
    And the list should be named "My Favorite Movies"

  Scenario: User edits a movie list
    Given I have a list named "My List"
    When I edit "My List"
    And I change the name to "Updated List"
    And I save the changes
    Then the list should be displayed as "Updated List"

  Scenario: User deletes a movie list
    Given I have a list named "My List"
    When I delete "My List"
    Then the list should be removed from my profile

  Scenario: Visitor views public list
    Given "alice" has a public list named "Top 10 Movies"
    And I am not logged in
    When I visit "alice"'s profile
    Then I should see "Top 10 Movies" list
    And I should be able to view the list contents

  Scenario: Visitor cannot view private list
    Given "alice" has a private list named "Private List"
    And I am not logged in
    When I try to view "alice"'s private list
    Then I should see a restricted access message

  Scenario: Visitor views empty public list
    Given "alice" has an empty public list
    And I am not logged in
    When I view "alice"'s list
    Then I should see an empty state message

  Scenario: Visitor clicks movie in public list
    Given "alice" has a public list with movies
    And I am not logged in
    When I click a movie in "alice"'s list
    Then I should be taken to the movie's detail page
