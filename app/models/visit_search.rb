# frozen_string_literal: true

class VisitSearch
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::AttributeAssignment

  attribute :url, :string, default: -> { "" }
  attribute :referrer, :string, default: -> { "" }
  attribute :start_date, :date, default: -> { 1.month.ago.to_date }
  attribute :end_date, :date, default: -> { Time.zone.today }
end
