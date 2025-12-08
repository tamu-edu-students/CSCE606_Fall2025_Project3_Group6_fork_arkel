Feature: User registration
  As a visitor
  I want to sign up
  So I can use the site

  Scenario: Sign up successfully
    Given I am not logged in
    When I register with email "newuser@example.com" and username "newbie"
    Then I should see a confirmation notice

  Scenario: Registration link from sign in page
    Given I am not logged in
    When I open the sign in page from the navbar
    And I follow the registration link
    Then I should see the sign up form
