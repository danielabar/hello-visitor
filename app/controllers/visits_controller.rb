# frozen_string_literal: true

class VisitsController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]
  before_action :log_request, only: %i[create]
  skip_forgery_protection

  def index
    @visit_search = VisitSearch.new
    @visit_search.assign_attributes(visit_search_params) if params[:visit_search].present?
    @stats = Stats.new(@visit_search)
    @stats.collect

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @stats.raw_data }
    end
  end

  def show
    @visit = Visit.find(params[:id])

    render json: { visits: @visit }
  end

  def create
    @visit = Visit.new(visit_params)
    @visit.remote_ip = request.remote_ip
    sanitize

    if @visit.save
      Rails.logger.info("Visit saved: #{@visit.to_json}")
    else
      Rails.logger.error("Visit error: #{@visit.errors}")
    end
    render json: {}
  end

  private

  def visit_params
    params.require(:visit).permit(:guest_timezone_offset, :user_agent, :url, :referrer)
  end

  def visit_search_params
    params.require(:visit_search).permit(:url, :referrer, :start_date, :end_date)
  end

  # https://stackoverflow.com/questions/3985989/using-sanitize-within-a-rails-controller
  def sanitize
    @visit.user_agent = ActionController::Base.helpers.sanitize(@visit.user_agent)
    @visit.url = ActionController::Base.helpers.sanitize(@visit.url)
  end

  def log_request
    Rails.logger.info("=== url = #{request.url}, host = #{request.host}, domain = #{request.domain},\
      protocol = #{request.protocol}, port = #{request.port}")
  end
end
