class CheckinsController < ApplicationController
  before_action :authenticate_user!

  def index
    @events = Event.where("date >= ? AND date <= ?", Date.today - 2.days, Date.today + 2.days)
                   .order('date ASC')
    set_notice
    render :layout => 'checkin_layout'
  end

  def new
    @event = Event.find(params[:event_id])
    set_notice
    render :layout => 'checkin_layout'
  end

  def create
    event = Event.find(checkin_params[:event_id])
    member = Member.find(checkin_params[:member_id])

    checkin = Checkin.where(event: event, member_id: member.id).first_or_create
    render json: member.attributes.slice(*%w(id first_name last_name)).to_json
  end

  private

  def checkin_params
    params.require(:checkin).permit(:event_id, :member_id)
  end

  def set_notice
    @notice = params[:completed_checkin] ? "Thanks for checking in! Enjoy the event." : 'Welcome!'
  end
end
