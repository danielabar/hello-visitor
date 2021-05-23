class Document < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_doc,
                  against: %i[title description category body],
                  using: { tsearch: { dictionary: 'english' } }

  validates :title, presence: true, uniqueness: true
  validates :body, presence: true

  # TODO: log searches in a table: search_log
  def self.search(query)
    docs = Document.search_doc(query).limit(Rails.configuration.search['max_search_results'])
    Rails.logger.info("Search: query = #{query}, num results = #{docs.length}, \
      titles = #{docs.map(&:title)}")
    docs.map(&:to_api)
  end

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
