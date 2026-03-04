# frozen_string_literal: true

class AddIndexToVisitsCreatedAt < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :visits, :created_at, algorithm: :concurrently
  end
end
