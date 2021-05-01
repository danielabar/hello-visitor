class VisitsController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]
  skip_forgery_protection

  def index
    range = determine_range(params)
    @stats = Stats.new(range[:start], range[:end])
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

  # TODO: if range_start/end can't be parsed (i.e. invalid date given), raise error...
  def determine_range(params)
    range_start = params[:range_start] ? Time.zone.parse(params[:range_start]) : Time.zone.now - 1.year
    range_end = params[:range_end] ? Time.zone.parse(params[:range_end]) : Time.zone.now
    {
      start: range_start,
      end: range_end
    }
  end
end
