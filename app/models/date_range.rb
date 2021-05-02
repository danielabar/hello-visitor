class DateRange
  attr_reader :start_date, :end_date

  def initialize(start_date, end_date)
    @start_date = Time.zone.parse(start_date || '') || Time.zone.now - 1.year
    @end_date = Time.zone.parse(end_date || '') || Time.zone.now
  end

  # https://stackoverflow.com/questions/19595840/rails-get-the-time-difference-in-hours-minutes-and-seconds
  def num_days
    (date_diff / 86_400).to_i
  end

  private

  def date_diff
    @end_date - @start_date
  end
end
