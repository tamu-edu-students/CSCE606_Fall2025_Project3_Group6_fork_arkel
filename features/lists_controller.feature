Feature: Lists controller flows
  As a signed-in user
  I want to manage lists
  So I can curate and control visibility

  Background:
    Given I am logged in as a user

  Scenario: Create a new public list successfully
    When I create a list named "Public List" with description "Desc" and public true
    Then I should see a list created notice

  Scenario: Fail to create list without name
    When I create a list named "" with description "Desc" and public false
    Then I should see a list validation error

  Scenario: Update a list successfully
    Given I have a personal list and movie
    When I update my list name to "Updated List"
    Then I should see a list updated notice

  Scenario: Destroy a list
    Given I have a personal list and movie
    When I delete my list
    Then I should see a list deleted notice

  Scenario: Guest cannot view private list
    Given I have a personal list and movie
    And I sign out
    When I visit the private list page
    Then I should see a private list alert

  Scenario: Lists index shows only my lists
    Given I have a personal list and movie
    When I visit my lists index
    Then I should see my list in the index

  Scenario: Guest is redirected when visiting lists index
    Given I have a personal list and movie
    And I sign out
    When I visit my lists index
    Then I should see a sign in prompt

  Scenario: Owner can view their private list
    Given I have a personal list and movie
    When I visit my private list as owner
    Then I should see the list details

  Scenario: Guest can view public list
    Given there is a public list
    And I sign out
    When I visit the public list page
    Then I should see the public list details

  Scenario: Owner can view edit page
    Given I have a personal list and movie
    When I visit my list edit page
    Then I should see the edit list form

  Scenario: Non-owner cannot edit list
    Given another user has a public list
    When I visit their list edit page
    Then I should see a not authorized alert

  Scenario: Update list fails validation
    Given I have a personal list and movie
    When I update my list name to ""
    Then I should see the edit list form

  Scenario: Non-owner cannot delete list
    Given another user has a public list
    When I attempt to delete their list
    Then I should see a not authorized alert
