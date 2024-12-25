# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents do |t|
      t.string :title, null: false
      t.text :description
      t.string :category
      t.date :published_at
      t.string :slug
      t.text :body, null: false

      t.timestamps
    end

    add_index :documents, :title, unique: true
  end
end
