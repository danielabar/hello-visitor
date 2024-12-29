@javascript
Feature: Visit Analysis

  Background:
    Given the following visits exist:
      | url                        | referrer                 | created_at    |
      | https://example.com/page1  | https://www.google.com   | 5.days.ago    |
      | https://example.com/page2  | https://t.co             | 3.days.ago    |
      | https://example.com/page3  | https://random.com       | 1.day.ago     |
      | https://example.com/page3  | https://linkedin.com     | 360.days.ago  |
    And I am logged in as any user

  Scenario: Search by content
    When I search by content "page1"
    Then the URL should contain "visit_search%5Burl%5D=page1"
    And the URL should contain "visit_search%5Bstart_date%5D="
    And the URL should contain "visit_search%5Bend_date%5D="

  Scenario: Search by referrer
    When I search by referrer "google"
    Then the URL should contain "visit_search%5Breferrer%5D=google"
    And the URL should contain "visit_search%5Bstart_date%5D="
    And the URL should contain "visit_search%5Bend_date%5D="

  Scenario: Search by date range
    When I search by date range from "2024-12-20" to "2024-12-21"
    Then the URL should contain "visit_search%5Bstart_date%5D=2024-12-20"
    And the URL should contain "visit_search%5Bend_date%5D=2024-12-21"
