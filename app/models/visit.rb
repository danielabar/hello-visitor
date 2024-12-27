# frozen_string_literal: true

class Visit < ApplicationRecord
  MAX_GROUPS = 15

  validates :guest_timezone_offset, presence: true
  validates :user_agent, presence: true
  validates :url, presence: true

  validate :not_a_bot

  def not_a_bot
    browser = Browser.new(user_agent, accept_language: "en-us")
    errors.add :user_agent, "No bots allowed" if browser.bot?
  end

  def self.summary(visit_search)
    sql = <<~SQL.squish
      select avg(visit_count)::numeric(10) as avg_daily_visits
        , sum(visit_count)::numeric(10) as total_visits
        , PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY visit_count)::numeric(10) as median_daily_visits
        , min(visit_count)::numeric(10) as min_visits
        , max(visit_count)::numeric(10) as max_visits
       FROM
      (SELECT created_at::timestamp::date as visit_date
           , count(created_at::timestamp::date) as visit_count
      FROM visits
      WHERE created_at >= ?
        AND created_at <= ?
        AND url like ?
        AND COALESCE(referrer, '') ILIKE ?
      GROUP BY created_at::timestamp::date) visits_by_day
    SQL
    visits = Visit.find_by_sql([sql, visit_search.start_date, visit_search.end_date, "%#{visit_search.url}%",
                                "%#{visit_search.referrer}%"])
    {
      avg_daily_visits: visits[0]["avg_daily_visits"],
      total_visits: visits[0]["total_visits"],
      median_daily_visits: visits[0]["median_daily_visits"],
      min_visits: visits[0]["min_visits"],
      max_visits: visits[0]["max_visits"]
    }
  end

  def self.by_page(visit_search)
    sql = <<~SQL.squish
      SELECT SPLIT_PART(url, ?, 1) as just_url
        , count(SPLIT_PART(url, ?, 1)) as page_count
      FROM visits
      WHERE created_at >= ?
        AND created_at <= ?
        AND url like ?
        AND COALESCE(referrer, '') ILIKE ?
      GROUP BY SPLIT_PART(url, ?, 1)
      ORDER BY count(SPLIT_PART(url, ?, 1)) desc
      LIMIT #{MAX_GROUPS}
    SQL
    visits = Visit.find_by_sql([sql, "?", "?", visit_search.start_date, visit_search.end_date, "%#{visit_search.url}%",
                                "%#{visit_search.referrer}%", "?", "?"])
    visits.map { |v| [v["just_url"], v["page_count"]] }
  end

  def self.by_referrer(visit_search)
    sql = <<~SQL.squish
      select trim(trailing '/' from referrer) as referrer
        , count(trim(trailing '/' from referrer)) as visit_count
      from visits
      where created_at >= ?
        AND created_at <= ?
        AND url like ?
        AND COALESCE(referrer, '') ILIKE ?
        and length(referrer) > 0
      group by trim(trailing '/' from referrer)
      order by count(trim(trailing '/' from referrer)) desc
      LIMIT #{MAX_GROUPS}
    SQL
    visits = Visit.find_by_sql([sql, visit_search.start_date, visit_search.end_date, "%#{visit_search.url}%",
                                "%#{visit_search.referrer}%"])
    visits.map { |v| [v["referrer"], v["visit_count"]] }
  end

  def self.by_date(visit_search)
    sql = <<-SQL.squish
      SELECT created_at::timestamp::date as visit_date
        , count(created_at::timestamp::date) as visit_count
      FROM visits
      WHERE created_at >= ?
        AND created_at <= ?
        AND url like ?
        AND COALESCE(referrer, '') ILIKE ?
      GROUP BY created_at::timestamp::date
      ORDER BY created_at::timestamp::date
    SQL
    visits = Visit.find_by_sql([sql, visit_search.start_date, visit_search.end_date, "%#{visit_search.url}%",
                                "%#{visit_search.referrer}%"])
    visits.map { |v| [v["visit_date"].strftime("%Y-%m-%d"), v["visit_count"]] }
  end
end
