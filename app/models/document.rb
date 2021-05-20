class Document < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_doc,
                  against: %i[title description category body],
                  using: { tsearch: { dictionary: 'english' } }
end
