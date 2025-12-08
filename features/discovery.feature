Feature: Discovery and recommendations
  As a visitor or signed-in user
  I want to browse discovery content
  So I can find trending and recommended movies

  Scenario: Signed-in user sees personalized recommendations and discovery rails
    Given I am logged in as a user
    And discovery data is available from TMDb
    And I have watched movies with tmdb ids 111 and 222
    When I visit the discovery page
    Then I should see personalized recommendations
    And I should see trending movies
    And I should see unwatched high rated movies

  Scenario: Guest sees discovery rails and sign in prompt
    Given discovery data is available from TMDb
    And I am not logged in
    When I visit the discovery page
    Then I should see trending movies
    And I should see unwatched high rated movies
    And I should be prompted to sign in for recommendations

  Scenario: Discovery handles API rate limit with cached data
    Given discovery data is available from TMDb
    And I am not logged in
    And TMDb rate limits discovery endpoints
    When I visit the discovery page
    Then I should see trending movies
