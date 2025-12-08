Feature: Stats service resilience
  As the system
  I want stats to handle errors gracefully

  Background:
    Given I am logged in as a user

  Scenario: Stats overview handles errors
    When I trigger stats overview with a failing movie query
    Then stats overview should not raise an error

  Scenario: Most watched movies handles errors
    When I trigger most watched movies with a failing query
    Then most watched movies should not raise an error

  Scenario: Update runtime handles tmdb errors
    Given a movie exists with tmdb id "7300" and no runtime
    When I trigger runtime update with failing tmdb
    Then runtime update should not raise an error
