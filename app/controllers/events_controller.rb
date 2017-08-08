class EventsController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]
  load_and_authorize_resource  only: [:new, :create, :edit, :update, :destroy]

  def index
    @upcoming_events = Event.where('date >= ?', Date.today)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)

  end

  private
  def event_params
    params.require(:event)
      .permit(:title, :date, :time, :description, :link, :link_text)
  end

end
