class SearchController < ApplicationController
  def index
    # TODO: Logic for default search term should go in Document.search method
    q = ActionController::Base.helpers.sanitize(params[:q] || Rails.configuration.search['default_search_term'])

    respond_to do |format|
      format.json { render json: Document.search(q) }
    end
  end
end
