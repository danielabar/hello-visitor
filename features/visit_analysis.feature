@javascript
Feature: Visit Analysis

  Background:
    Given the following visits exist:
      | url                        | referrer                 | created_at    |
      | https://example.com/page1  | https://www.google.com   | 5.days.ago    |
      | https://example.com/page2  | https://t.co             | 3.days.ago    |
      | https://example.com/page3  | https://google.ca        | 1.day.ago     |
      | https://example.com/page3  | https://linkedin.com     | 360.days.ago  |
    And I am logged in as any user

  Scenario: Default visits dashboard for past month
    Then the Summary section shows stats:
      | avg_daily_visits | total_visits | median_daily_visits | min_visits | max_visits |
      | 1                | 32            | 1                   | 1          | 1          |
    And charts are displayed

  Scenario: Search by content
    When I search by content "page1"
    Then the Summary section shows stats:
      | avg_daily_visits | total_visits | median_daily_visits | min_visits | max_visits |
      | 1                | 1            | 1                   | 1          | 1          |
    And charts are displayed

  Scenario: Search by referrer
    When I search by referrer "google"
    Then the Summary section shows stats:
      | avg_daily_visits | total_visits | median_daily_visits | min_visits | max_visits |
      | 1                | 2            | 1                   | 1          | 1          |
    And charts are displayed

  Scenario: Search by date range
    When I search for visits in the past year
    Then the Summary section shows stats:
      | avg_daily_visits | total_visits | median_daily_visits | min_visits | max_visits |
      | 1                | 4            | 1                   | 1          | 1          |
    And charts are displayed

  Scenario: No results
    When I search by content "no-such-thing"
    Then charts display no data
