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

  Scenario: User views their own profile with ID parameter
    When I visit my profile page with my user ID
    Then I should see my username on the profile
    And I should see my lists section

  Scenario: User views their own profile without ID parameter
    When I visit my profile page without ID
    Then I should see my username on the profile
    And I should see my recent reviews section

  Scenario: Viewing another user's public profile by ID
    Given there is a public user named "other_user"
    When I visit "other_user"'s profile by ID
    Then I should see "other_user"'s username
    And I should only see public lists

  Scenario: Viewing another user's private profile by ID
    Given there is a private user named "private_user"
    When I visit "private_user"'s profile by ID
    Then I should see a restricted access message
    And I should be redirected to the home page

  Scenario: Public profile by username shows user content
    Given there is a public user named "john_doe"
    And "john_doe" has reviews
    When I visit "john_doe"'s public profile by username
    Then I should see "john_doe"'s username
    And I should see their recent reviews

  Scenario: Private profile by username redirects
    Given there is a private user named "jane_private"
    When I visit "jane_private"'s public profile by username
    Then I should see a restricted access message
    And I should be redirected to the home page

  Scenario: User visits settings page
    When I visit my settings page
    Then I should see my settings
    And I should see my following list

  Scenario: User visits edit profile page
    When I visit my edit profile page
    Then I should see the edit profile form

  Scenario: User updates profile successfully
    When I visit my edit profile page
    And I update my username to "new_username"
    Then I should see a success message "Profile updated"
    And my username should be "new_username"

  Scenario: User updates profile with invalid data
    When I visit my edit profile page
    And I update my username to ""
    Then I should see the edit profile form
    And I should see validation errors

  Scenario: User updates profile privacy setting
    When I visit my edit profile page
    And I set my profile to private
    Then I should see a success message "Profile updated"
    And my profile should be private

  Scenario: Viewing reviews of a public user
    Given there is a public user named "reviewer"
    And "reviewer" has multiple reviews
    When I visit "reviewer"'s reviews page
    Then I should see all of "reviewer"'s reviews
    And reviews should be ordered by date

  Scenario: Viewing reviews of a private user is restricted
    Given there is a private user named "secret_reviewer"
    When I visit "secret_reviewer"'s reviews page
    Then I should see a restricted access message
    And I should be redirected to the home page

  Scenario: Viewing own reviews page
    Given I have multiple reviews
    When I visit my own reviews page
    Then I should see all my reviews
    And reviews should be ordered by date
