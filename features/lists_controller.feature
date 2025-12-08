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
