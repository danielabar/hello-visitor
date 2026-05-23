# frozen_string_literal: true

class AddTrigramIndexToVisitsUrl < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    enable_extension "pg_trgm"
    add_index :visits, :url, using: :gin,
                             opclass: :gin_trgm_ops,
                             algorithm: :concurrently
  end
end
