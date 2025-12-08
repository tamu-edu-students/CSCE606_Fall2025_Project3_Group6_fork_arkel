Feature: Profile page
  As a signed-in user
  I want to view my profile
  So I can see my info and lists

  Scenario: Viewing own profile
    Given I am logged in as a user
    When I visit my profile page
    Then I should see my username on the profile
    And I should see my lists section

  Scenario: Guest cannot view a private profile
    Given there is a private user named "locked_user"
    When I attempt to view "locked_user"'s profile
    Then I should see a restricted access message

  Scenario: Viewing another user's public profile
    Given there is a user named "public_user"
    And "public_user" has a public list named "Top Picks"
    When I visit "public_user"'s profile
    Then I should see "Top Picks" list

  Scenario: Profile shows recent reviews
    Given I am logged in as a user
    And I create a review with body "Profile review" and rating "8"
    When I visit my profile page
    Then I should see my review on the profile
