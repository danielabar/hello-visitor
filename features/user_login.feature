@javascript
Feature: User Login

  Background:
    Given a user exists with email "user@example.com" and password "password"

  Scenario: Successful login
    Given I visit the root path
    Then I should be redirected to the login page
    When I submit the login form with "user@example.com" and "password"
    Then I should be signed in

  Scenario: Unsuccessful login
    Given I visit the root path
    Then I should be redirected to the login page
    When I submit the login form with "user@example.com" and "incorrect_password"
    Then I should not be signed in
