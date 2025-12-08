Feature: Users controller privacy and settings
  As a user
  I want profile access to respect authentication and privacy

  Scenario: Redirect to sign in when accessing profile unauthenticated
    When I visit my profile page
    Then I should be signed out

  Scenario: Authenticated user sees own lists and stats
    Given I am logged in as a user
    When I visit my profile page
    Then I should see my username on the profile
    And I should see my lists section
