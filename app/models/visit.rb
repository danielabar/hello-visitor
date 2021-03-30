class Visit < ApplicationRecord
  validates :guest_timezone_offset, presence: true
  validates :user_agent, presence: true
  validates :url, presence: true

  def self.total_visits
    Visit
      .where('created_at >= ?', Time.zone.now - 1.year)
      .count
  end

  def self.by_page(total)
    sql = <<~SQL
      SELECT SPLIT_PART(url, ?, 1) as just_url
        , count(SPLIT_PART(url, ?, 1)) as page_count
      FROM visits
      WHERE created_at >= ?
      GROUP BY SPLIT_PART(url, ?, 1)
      ORDER BY count(SPLIT_PART(url, ?, 1)) desc
    SQL
    visits = Visit.find_by_sql([sql, '?', '?', Time.zone.now - 1.year, '?', '?'])
    visits.map { |v| StatsItem.new(v['just_url'], v['page_count'], total) }
  end
end
