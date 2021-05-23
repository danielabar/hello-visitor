class SearchController < ApplicationController
  # TODO: log searches in new table: search_log
  def index
    q = ActionController::Base.helpers.sanitize(params[:q] || Rails.configuration.search['default_search_term'])
    docs = Document.search_doc(q).limit(Rails.configuration.search['max_search_results'])
    results = docs.map(&:to_api)

    respond_to do |format|
      format.json { render json: results }
    end
  end
end
