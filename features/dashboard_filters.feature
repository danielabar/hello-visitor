Feature: Dashboard Search Filters
  As a user
  I want to filter visits by various criteria
  So that I can find relevant traffic data.

  Background:
    Given a user exists with email "user@example.com" and password "password"
    And I am logged in as "user@example.com" with password "password"
    And the following visits exist:
      | url                        | referrer            | created_at        |
      | https://example.com/page1  | https://www.google.com | 2024-12-20 10:00 |
      | https://example.com/page2  | https://t.co          | 2024-12-21 12:00 |
      | https://example.com/page3  | https://random.com    | 2024-12-22 14:00 |

  Scenario: Search by content
    When I fill in "Content" with "page1"
    And I click "Search"
    Then I should see "https://example.com/page1"
    And I should not see "https://example.com/page2"

  Scenario: Search by referrer
    When I fill in "Referrer" with "google"
    And I click "Search"
    Then I should see "https://www.google.com"
    And I should not see "https://t.co"

  Scenario: Search by date range
    When I fill in "Start date" with "2024-12-20"
    And I fill in "End date" with "2024-12-21"
    And I click "Search"
    Then I should see "https://example.com/page1"
    And I should see "https://example.com/page2"
    And I should not see "https://example.com/page3"
