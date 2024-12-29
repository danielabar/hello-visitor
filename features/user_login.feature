Feature: User Login and Dashboard Access
  As a user
  I want to log in and view the visits dashboard
  So that I can analyze website traffic.

  Background:
    Given a user exists with email "user@example.com" and password "password"

  Scenario: Successful login and view dashboard
    Given I visit the login page
    When I fill in "Email" with "user@example.com"
    And I fill in "Password" with "password"
    And I click "Log in"
    Then I should see "Visits by Date"
    And I should see "Filter"

  Scenario: Redirect to login when unauthenticated
    Given I visit the visits dashboard page
    Then I should be redirected to the login page
    And I should see "You need to sign in or sign up before continuing."
