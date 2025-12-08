Feature: Notifications
  As a signed-in user
  I want to see my notifications
  So I can react to follower and activity updates

  Scenario: Viewing notifications list
    Given I am logged in as a user
    And I have a notification
    When I visit my notifications page
    Then I should see my notification
    And I can mark it as read

  Scenario: Mark all notifications as read
    Given I am logged in as a user
    And I have multiple unread notifications
    When I visit my notifications page
    And I mark all notifications as read
    Then I should not see unread notification actions

  Scenario: Empty notifications state
    Given I am logged in as a user
    When I visit my notifications page
    Then I should see an empty notifications state
