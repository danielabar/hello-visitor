# frozen_string_literal: true

class AddReferrerGroupToVisits < ActiveRecord::Migration[8.1]
  def change
    add_column :visits, :referrer_group, :string
  end
end
