class VisitsController < ApplicationController
  before_action :authenticate_user!, only: %i[index show]
  skip_forgery_protection

  def index
    # TODO: Paginate
    @visits = Visit.all

    render json: { visits: @visits }
  end

  def show
    @visit = Visit.find(params[:id])

    render json: { visits: @visit }
  end

  def create
    @visit = Visit.new(visit_params)
    @visit.remote_ip = request.remote_ip
    # Nice to have: https://stackoverflow.com/questions/1988049/getting-a-user-country-name-from-originating-ip-address-with-ruby-on-rails
    sanitize

    if @visit.save
      render json: { visits: @visit }
      Rails.logger.info("Visit saved: #{@visit.to_json}")
    else
      render json: { error: @visit.errors }
    end
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
