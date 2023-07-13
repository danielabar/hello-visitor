class Stats
  attr_reader :visits, :summary, :by_page, :by_referrer, :by_date, :raw_data

  def initialize(start_date, end_date, url)
    @start_date = start_date
    @end_date = end_date
    @url = url
  end

  def collect
    @visits = Visit.limit(100).order(created_at: :desc)
    @summary = Visit.summary(@start_date, @end_date, @url)
    @by_page = Visit.by_page(@start_date, @end_date, @url)
    @by_referrer = Visit.by_referrer(@start_date, @end_date, @url)
    @by_date = Visit.by_date(@start_date, @end_date, @url)
    @raw_data = { summary: @summary,
                  by_page: @by_page, by_date: @by_date, by_referrer: @by_referrer, visits: @visits.map(&:raw_data) }
  end
end
