class AddExcerptToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :excerpt, :text
  end
end
