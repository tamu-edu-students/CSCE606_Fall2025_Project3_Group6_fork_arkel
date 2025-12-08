Feature: Notification mailer
  As a system
  I want to send notification emails
  So users receive messages with optional links

  Scenario: Send notification email with CTA
    Given I am a registered user
    When I send a notification email with message "Hello!" and url "/movies"
    Then the notification email should be delivered with subject "One Notification from Cinematico"
    And the email body should include "Hello!"
