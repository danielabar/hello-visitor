# frozen_string_literal: true

class Stats
  attr_reader :visits, :summary, :by_page, :by_referrer, :by_date, :raw_data

  def initialize(visit_search)
    @visit_search = visit_search
  end

  def collect
    @visits = Visit.limit(100).order(created_at: :desc)
    @summary = Visit.summary(@visit_search)
    @by_page = Visit.by_page(@visit_search)
    @by_referrer = Visit.by_referrer(@visit_search)
    @by_date = Visit.by_date(@visit_search)
    @raw_data = { summary: @summary,
                  by_page: @by_page, by_date: @by_date, by_referrer: @by_referrer, visits: @visits }
  end
end
