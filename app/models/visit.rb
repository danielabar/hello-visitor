# frozen_string_literal: true

class Visit < ApplicationRecord
  validates :guest_timezone_offset, presence: true
  validates :user_agent, presence: true
  validates :url, presence: true

  validate :not_a_bot

  def not_a_bot
    browser = Browser.new(user_agent, accept_language: "en-us")
    errors.add :user_agent, "No bots allowed" if browser.bot?
  end

  def self.summary(visit_search)
    result = VisitQuery.summary(visit_search)
    {
      avg_daily_visits: result[0]["avg_daily_visits"],
      total_visits: result[0]["total_visits"],
      median_daily_visits: result[0]["median_daily_visits"],
      min_visits: result[0]["min_visits"],
      max_visits: result[0]["max_visits"]
    }
  end

  def self.by_page(visit_search)
    VisitQuery.by_page(visit_search).map { |v| [v["just_url"], v["page_count"]] }
  end

  def self.by_page_bottom(visit_search)
    VisitQuery.by_page_bottom(visit_search).map { |v| [v["just_url"], v["page_count"]] }
  end

  def self.by_referrer(visit_search)
    VisitQuery.by_referrer(visit_search).map { |v| [v["referrer"], v["visit_count"]] }
  end

  def self.by_date(visit_search)
    VisitQuery.by_date(visit_search).map { |v| [v["visit_date"].strftime("%Y-%m-%d"), v["visit_count"]] }
  end
end
