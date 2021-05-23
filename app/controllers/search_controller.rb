class SearchController < ApplicationController
  # TODO: default search term should come from config/env var
  # TODO: max number of search results shoudl come from config/env var
  # TODO: log searches in new table: search_log
  def index
    q = ActionController::Base.helpers.sanitize(params[:q] || 'programming')
    docs = Document.search_doc(q).limit(3)
    results = docs.map(&:to_api)

    respond_to do |format|
      format.json { render json: results }
    end
  end
end
