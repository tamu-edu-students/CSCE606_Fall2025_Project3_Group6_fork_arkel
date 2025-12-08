Feature: Reviews
  As a signed-in user
  I want to review movies
  So I can share my thoughts

  Background:
    Given I am logged in as a user

  Scenario: Create a review
    Given a movie exists with tmdb id "7200"
    When I create a review with body "An insightful take" and rating "9"
    Then I should see my review on the movie page

  Scenario: Review body too short shows an error
    Given a movie exists with tmdb id "7201"
    When I attempt to create a short review
    Then I should see a review error message

  Scenario: Update an existing review
    Given a movie exists with tmdb id "7202"
    And I create a review with body "Old body content" and rating "7"
    When I update my review body to "Updated body content" and rating to "8"
    Then I should see my updated review on the movie page

  Scenario: Delete an existing review
    Given a movie exists with tmdb id "7203"
    And I create a review with body "Review to delete" and rating "6"
    When I delete my review
    Then I should not see my review on the movie page
