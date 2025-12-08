Feature: Watch history edge cases
  As a signed-in user
  I want graceful errors when logging watches

  Background:
    Given I am logged in as a user

  Scenario: Logging a watch for unknown movie shows alert
    When I log an unknown movie id to my watch history
    Then I should see a watch history alert
