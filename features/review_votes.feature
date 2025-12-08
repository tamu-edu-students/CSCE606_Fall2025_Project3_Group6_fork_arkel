Feature: Review voting
  As a signed-in user
  I want to upvote and unvote reviews

  Background:
    Given I am logged in as a user
    And a published review exists

  Scenario: Upvoting a review
    When I upvote the review
    Then I should see my vote recorded

  Scenario: Toggling an existing vote removes it
    Given I have already upvoted the review
    When I upvote the review
    Then I should see my vote removed

  Scenario: Reporting a review sets reported flag
    When I report the review
    Then I should see a review reported notice
