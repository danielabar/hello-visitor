# frozen_string_literal: true

# Make a model out of visit search so that values can be bound to the UI form.
class VisitSearch
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment

  attribute :url, :string
  attribute :referrer, :string
  attribute :start_date, :date, default: -> { 1.month.ago.to_date }
  attribute :end_date, :date, default: -> { Time.zone.today }
end
