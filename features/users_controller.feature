Feature: Users controller visibility
  As a visitor or owner
  I want profiles and reviews to respect privacy

  Background:
    Given I am logged in as a user

  Scenario: Private profile redirects
    Given there is a private user named "locked_profile"
    When I visit "locked_profile"'s profile
    Then I should see a restricted access message
    And I should be redirected to the home page

  Scenario: Public profile shows reviews
    Given there is a user named "public_profile"
    And "public_profile" has a public list named "Open List"
    When I visit "public_profile"'s profile
    Then I should see "Open List" list
