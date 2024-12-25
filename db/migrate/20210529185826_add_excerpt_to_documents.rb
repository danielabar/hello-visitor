# frozen_string_literal: true

class AddExcerptToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :excerpt, :text
  end
end
