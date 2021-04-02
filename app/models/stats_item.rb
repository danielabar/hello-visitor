# TODO: No longer used
class StatsItem
  attr_reader :value, :count

  def initialize(value, count, total)
    @value = value
    @count = count
    @total = total
  end

  def percentage
    @count / @total.to_f
  end
end
