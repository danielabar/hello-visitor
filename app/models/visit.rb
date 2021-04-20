class Visit < ApplicationRecord
  MAX_GROUPS = 15

  validates :guest_timezone_offset, presence: true
  validates :user_agent, presence: true
  validates :url, presence: true

  def self.total_visits
    Visit
      .where('created_at >= ?', Time.zone.now - 1.year)
      .count
  end

  # TODO: total and average daily visits in one query - uses subselect
  # select avg(visit_count)::numeric(10)
  #   , sum(visit_count) FROM
  # (SELECT created_at::timestamp::date as visit_date
  #      , count(created_at::timestamp::date) as visit_count
  # FROM visits
  # GROUP BY created_at::timestamp::date) myalias

  def self.by_page
    sql = <<~SQL.squish
      SELECT SPLIT_PART(url, ?, 1) as just_url
        , count(SPLIT_PART(url, ?, 1)) as page_count
      FROM visits
      WHERE created_at >= ?
      GROUP BY SPLIT_PART(url, ?, 1)
      ORDER BY count(SPLIT_PART(url, ?, 1)) desc
      LIMIT #{MAX_GROUPS}
    SQL
    visits = Visit.find_by_sql([sql, '?', '?', Time.zone.now - 1.year, '?', '?'])
    visits.map { |v| [v['just_url'], v['page_count']] }
  end

  def self.by_referrer
    sql = <<~SQL.squish
      select trim(trailing '/' from referrer) as referrer
        , count(trim(trailing '/' from referrer)) as visit_count
      from visits
      where created_at >= ?
        and length(referrer) > 0
      group by trim(trailing '/' from referrer)
      order by count(trim(trailing '/' from referrer)) desc
      LIMIT #{MAX_GROUPS}
    SQL
    visits = Visit.find_by_sql([sql, Time.zone.now - 1.year])
    visits.map { |v| [v['referrer'], v['visit_count']] }
  end

  def self.by_date
    sql = <<-SQL.squish
      SELECT created_at::timestamp::date as visit_date
        , count(created_at::timestamp::date) as visit_count
      FROM visits
      WHERE created_at >= ?
      GROUP BY created_at::timestamp::date
      ORDER BY created_at::timestamp::date
    SQL
    visits = Visit.find_by_sql([sql, Time.zone.now - 1.year])
    visits.map { |v| [v['visit_date'].strftime('%Y-%m-%d'), v['visit_count']] }
  end
end
