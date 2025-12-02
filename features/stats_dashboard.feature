Feature: Stats Dashboard
  As a user
  I want to view my movie watching statistics
  So I can track my viewing activity

  Background:
    Given the TMDb API is available
    And I am logged in as a user

  Scenario: View stats overview with logged movies
    Given I have logged movies
    When I visit the stats page
    Then I should see all overview metrics
    And I should see the total movies watched
    And I should see the total hours watched
    And I should see the total reviews written
    And I should see the total rewatches
    And I should see the genre breakdown

  Scenario: View stats overview with no logged movies
    Given I have no logged movies
    When I visit the stats page
    Then I should see an empty-state message
    And I should see a link to browse movies

  Scenario: Stats update after adding new log
    Given I have logged movies
    When I visit the stats page
    And I note the current total movies count
    And I add a new log entry
    And I refresh the stats page
    Then the totals should update accordingly

  Scenario: View top contributors
    Given I have logged movies with metadata
    When I visit the stats page
    Then I should see the top three genres
    And I should see my most-watched directors
    And I should see my most-watched actors

  Scenario: View top contributors with missing metadata
    Given I have logged movies without metadata
    When I visit the stats page
    Then I should see top genres if available
    And I should see a message for missing directors
    And I should see a message for missing actors

  Scenario: View trend charts with sufficient data
    Given I have enough log data for trends
    When I visit the stats page
    Then I should see the activity trend chart
    And I should see the rating trend chart
    And the charts should display data points

  Scenario: View trend charts with insufficient data
    Given I have insufficient log data
    When I visit the stats page
    Then I should see a placeholder for charts
    And I should see a message to log more movies

  Scenario: Trend charts update after adding logs
    Given I have enough log data for trends
    When I visit the stats page
    And I note the current trend data
    And I add new logs with dates
    And I refresh the stats page
    Then the trend lines should update

  Scenario: View activity heatmap with logs
    Given I have logs with dates
    When I visit the stats page
    Then I should see the activity heatmap
    And active days should be highlighted
    And I should see color intensity based on activity

  Scenario: View activity heatmap with no logs
    Given I have no logs with dates
    When I visit the stats page
    Then I should see an empty heatmap grid
    And I should see a message about no activity data

  Scenario: Heatmap updates after adding log
    Given I have logs with dates
    When I visit the stats page
    And I add a new log with today's date
    And I refresh the stats page
    Then the corresponding day should be highlighted

  @no-background
  Scenario: Access stats page without authentication
    Given I am not logged in
    When I try to visit the stats page
    Then I should be redirected to the login page

