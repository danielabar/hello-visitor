class VisitsController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]
  skip_forgery_protection

  def index
    @visits = Visit.limit(100).order(created_at: :desc)
    @total_visits = Visit.total_visits
    @by_page = Visit.by_page(@total_visits)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: { total_visits: @total_visits, by_page: @by_page, visits: @visits } }
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
end
