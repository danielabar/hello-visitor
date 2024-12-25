# frozen_string_literal: true

# Make a model out of visit search so that values can be bound to the UI form.
class VisitSearch
  include ActiveModel::Model
  attr_accessor :url
end
