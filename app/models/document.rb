class Document < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_doc,
                  against: %i[title description category body],
                  using: { tsearch: { dictionary: 'english' } }

  validates :title, presence: true, uniqueness: true
  validates :body, presence: true

  def to_api
    {
      title: title,
      description: description,
      category: category,
      published_at: published_at,
      slug: slug
    }
  end
end
