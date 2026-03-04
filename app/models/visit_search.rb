# frozen_string_literal: true

# TODO: Validation
class VisitSearch
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment

  attribute :url, :string, default: -> { "" }
  attribute :referrer, :string, default: -> { "" }
  attribute :start_date, :date, default: -> { 1.month.ago.to_date }
  attribute :end_date, :date, default: -> { Time.zone.today }
  attribute :granularity, :string, default: "day"

  def monthly?
    granularity == "month"
  end

  def start_datetime
    start_date&.beginning_of_day
  end

  def end_datetime
    end_date&.end_of_day
  end
end
