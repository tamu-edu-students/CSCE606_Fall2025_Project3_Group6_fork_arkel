Feature: User authentication and login
  As a visitor
  I want to sign in and out
  So that I can access protected pages

  Scenario: Successful sign in
    Given I am a registered user
    When I sign in with valid credentials
    Then I should be signed in

  Scenario: Sign in from navbar
    Given I am not logged in
    When I open the sign in page from the navbar
    Then I should see the sign in form

  Scenario: Sign in required for protected pages
    Given I am not logged in
    When I attempt to visit my watchlist
    Then I should see the sign in form

  Scenario: Failed sign in with invalid credentials
    Given I am a registered user
    When I attempt to sign in with an invalid password
    Then I should see a sign in error

  Scenario: Sign out
    Given I am a registered user
    And I am signed in
    When I sign out
    Then I should be signed out
