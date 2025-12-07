Feature: Stats Dashboard
  As a user
  I want to view my movie watching statistics
  So I can track my viewing habits

  Background:
    Given I am logged in as a user

  Scenario: User views stats overview with logged movies
    Given I have logged 5 movies
    When I visit my stats page
    Then I should see my total movies watched
    And I should see my total hours watched
    And I should see my total reviews
    And I should see my rewatch count
    And I should see my genre breakdown

  Scenario: User views stats overview with no logged movies
    Given I have no logged movies
    When I visit my stats page
    Then I should see an empty state message

  Scenario: Stats update after adding new log entry
    Given I have logged 3 movies
    And I visit my stats page
    When I log a new movie
    And I refresh the stats page
    Then my total movies watched should increase

  Scenario: User views top contributors
    Given I have logged movies with different genres and directors
    When I visit my stats page
    Then I should see my top three genres
    And I should see my most-watched directors
    And I should see my most-watched actors

  Scenario: User views full ranked list of top contributors
    Given I have logged movies with different genres
    When I visit my stats page
    And I click "View All" for genres
    Then I should see a full ranked list of genres

  Scenario: User views trend charts with sufficient data
    Given I have logged movies across multiple months
    When I visit my stats page
    Then I should see activity trend chart
    And I should see rating trend chart

  Scenario: User views trend charts with insufficient data
    Given I have logged only one movie
    When I visit my stats page
    Then I should see a placeholder for the charts

  Scenario: Trend charts update after adding new logs
    Given I have logged movies in January
    And I visit my stats page
    When I log a movie in February
    And I refresh the stats page
    Then the trend lines should update

  Scenario: User views heatmap activity
    Given I have logged movies on different days
    When I visit my stats page
    Then I should see the activity heatmap
    And active days should be highlighted

  Scenario: User views empty heatmap
    Given I have no logged movies
    When I visit my stats page
    Then I should see an empty heatmap grid

  Scenario: Heatmap updates after adding new log
    Given I have logged movies
    And I visit my stats page
    When I log a new movie today
    And I refresh the stats page
    Then today should be highlighted in the heatmap
