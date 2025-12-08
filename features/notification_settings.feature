Feature: Notification preferences
  As a signed-in user
  I want to manage notification settings
  So I can control alerts

  Background:
    Given I am logged in as a user
    And supporting preference models are loaded

  Scenario: Update notification preferences
    When I visit my notification preferences page
    And I disable all notification toggles
    Then I should see a success message for notification preferences
