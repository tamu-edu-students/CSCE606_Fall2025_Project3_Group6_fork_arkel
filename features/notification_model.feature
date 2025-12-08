Feature: Notification model behaviors
  As the system
  I want notifications to track read/unread and payload data

  Scenario: Mark notification as read/unread with read_at
    Given a notification with read_at column
    When I mark it as read and unread
    Then the notification read flags should toggle correctly

  Scenario: Mark notification as delivered
    Given a notification with delivered_at column
    When I mark it delivered
    Then the notification delivered flag should be set

  Scenario: Notification payload and as_json include data and recipient
    Given a notification with JSON data and recipient_id
    Then the payload should return a hash
    And as_json should include recipient and data keys
