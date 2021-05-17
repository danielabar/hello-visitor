class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents do |t|
      t.string :title
      t.text :description
      t.string :category
      t.date :published_at
      t.string :slug
      t.text :body

      t.timestamps
    end
  end
end
