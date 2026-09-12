# frozen_string_literal: true

class AddIndexToVisitsReferrerGroup < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :visits, :referrer_group, algorithm: :concurrently
  end
end
