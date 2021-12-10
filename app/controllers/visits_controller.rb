class VisitsController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]
  before_action :log_request, only: %i[create]
  skip_forgery_protection

  def index
    @date_range = DateRange.new(params[:range_start], params[:range_end])
    @stats = Stats.new(@date_range.start_date, @date_range.end_date, params[:url])
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

  # https://stackoverflow.com/questions/3985989/using-sanitize-within-a-rails-controller
  def sanitize
    @visit.user_agent = ActionController::Base.helpers.sanitize(@visit.user_agent)
    @visit.url = ActionController::Base.helpers.sanitize(@visit.url)
  end

  def log_request
    Rails.logger.info("=== url = #{request.url}, host = #{request.host}, domain = #{request.domain}, protocol = #{request.protocol}, port = #{request.port}")
  end
end
