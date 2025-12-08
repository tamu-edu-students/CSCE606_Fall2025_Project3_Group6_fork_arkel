Feature: Application helper formatting and poster helpers
  Scenario: Format valid and invalid dates
    When I format the date "2025-12-01"
    Then the formatted date should be "2025"
    When I format an invalid date
    Then the formatted date should be nil

  Scenario: Poster placeholder helpers
    Then the poster placeholder url should be a data uri
    And poster_url_for blank returns placeholder
    And poster_is_placeholder? returns true for placeholder url
