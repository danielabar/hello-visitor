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

  Scenario: Default visits dashboard for past month
    Then the Summary section shows stats:
      | avg_daily_visits | total_visits | median_daily_visits | min_visits | max_visits |
      | 1                | 3            | 1                   | 1          | 1          |
    And charts are displayed

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
    When I search for visits in the past year
    Then the Summary section shows stats:
      | avg_daily_visits | total_visits | median_daily_visits | min_visits | max_visits |
      | 1                | 4            | 1                   | 1          | 1          |
    And charts are displayed
