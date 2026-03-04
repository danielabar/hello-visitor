# frozen_string_literal: true

class Stats
  attr_reader :visits, :summary, :by_page, :by_page_bottom, :by_referrer, :by_date, :by_month, :raw_data

  def initialize(visit_search)
    @visit_search = visit_search
  end

  def collect
    @visits         = Visit.limit(100).order(created_at: :desc)
    @summary        = @visit_search.monthly? ? Visit.monthly_summary(@visit_search) : Visit.summary(@visit_search)
    @by_page        = Visit.by_page(@visit_search)
    @by_page_bottom = Visit.by_page_bottom(@visit_search)
    @by_referrer    = Visit.by_referrer(@visit_search)
    @by_month       = Visit.by_month(@visit_search) if @visit_search.monthly?
    @by_date        = Visit.by_date(@visit_search) unless @visit_search.monthly?
    @raw_data = { summary: @summary,
                  by_page: @by_page,
                  by_page_bottom: @by_page_bottom,
                  by_date: @by_date,
                  by_month: @by_month,
                  by_referrer: @by_referrer,
                  visits: @visits }
  end
end
