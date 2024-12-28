# frozen_string_literal: true

class VisitQuery
  MAX_GROUPS = 10
  MAX_GROUPS_BOTTOM = 5

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
    Visit.find_by_sql([sql, visit_search.start_datetime, visit_search.end_datetime, "%#{visit_search.url}%",
                       "%#{visit_search.referrer}%"])
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
    Visit.find_by_sql([sql, "?", "?", visit_search.start_datetime, visit_search.end_datetime, "%#{visit_search.url}%",
                       "%#{visit_search.referrer}%", "?", "?"])
  end

  def self.by_page_bottom(visit_search)
    sql = <<~SQL.squish
      SELECT SPLIT_PART(url, ?, 1) as just_url
        , count(SPLIT_PART(url, ?, 1)) as page_count
      FROM visits
      WHERE created_at >= ?
        AND created_at <= ?
        AND url like ?
        AND COALESCE(referrer, '') ILIKE ?
      GROUP BY SPLIT_PART(url, ?, 1)
      ORDER BY count(SPLIT_PART(url, ?, 1)) ASC
      LIMIT #{MAX_GROUPS_BOTTOM}
    SQL
    Visit.find_by_sql([sql, "?", "?", visit_search.start_datetime, visit_search.end_datetime, "%#{visit_search.url}%",
                       "%#{visit_search.referrer}%", "?", "?"])
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
    Visit.find_by_sql([sql, visit_search.start_datetime, visit_search.end_datetime, "%#{visit_search.url}%",
                       "%#{visit_search.referrer}%"])
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
    Visit.find_by_sql([sql, visit_search.start_datetime, visit_search.end_datetime, "%#{visit_search.url}%",
                       "%#{visit_search.referrer}%"])
  end
end
