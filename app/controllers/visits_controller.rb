# frozen_string_literal: true

class VisitsController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]
  before_action :log_request, only: %i[create]
  skip_forgery_protection only: :create

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
    @visit = Visit.find(params.expect(:id))

    render json: { visits: @visit }
  end

  def create
    @visit = IncomingVisit.new(params: visit_params, remote_ip: request.remote_ip).build

    if @visit.save
      Rails.logger.info("Visit saved: id=#{@visit.id}, url=#{@visit.url}")
    else
      Rails.logger.error("Visit error: #{@visit.errors}")
    end
    render json: {}
  end

  private

  def visit_params
    params.expect(visit: %i[guest_timezone_offset user_agent url referrer])
  end

  def visit_search_params
    params.expect(visit_search: %i[url referrer start_date end_date granularity])
  end

  def log_request
    Rails.logger.info("=== url = #{request.url}, host = #{request.host}, domain = #{request.domain},\
      protocol = #{request.protocol}, port = #{request.port}")
  end
end
