@javascript
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
    Then the URL should contain "visit_search%5Burl%5D=page1"
    And the URL should contain "visit_search%5Bstart_date%5D="
    And the URL should contain "visit_search%5Bend_date%5D="

  Scenario: Search by referrer
    When I fill in "Referrer" with "google"
    And I click "Search"
    Then the URL should contain "visit_search%5Breferrer%5D=google"
    And the URL should contain "visit_search%5Bstart_date%5D="
    And the URL should contain "visit_search%5Bend_date%5D="

  Scenario: Search by date range
    When I fill in "Start date" with "2024-12-20"
    And I fill in "End date" with "2024-12-21"
    And I click "Search"
    Then the URL should contain "visit_search%5Bstart_date%5D=2024-12-20"
    And the URL should contain "visit_search%5Bend_date%5D=2024-12-21"
