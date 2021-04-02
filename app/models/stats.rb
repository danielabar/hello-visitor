class Stats
  attr_reader :visits, :total_visits, :by_page, :by_date, :raw_data

  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  # Future: pass start/end dates to Visit model methods to limit data returned
  def collect
    @visits = Visit.limit(100).order(created_at: :desc)
    @total_visits = Visit.total_visits
    @by_page = Visit.by_page
    @by_date = Visit.by_date
    @raw_data = { total_visits: @total_visits, by_page: @by_page, by_date: @by_date, visits: @visits }
  end
end
