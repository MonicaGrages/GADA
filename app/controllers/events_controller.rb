class EventsController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]
  load_and_authorize_resource  only: [:new, :create, :edit, :update, :destroy]

  def index
    @events = Event.where('date >= ?', Date.today)
    @upcoming_events = @events.order('date ASC')
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    respond_to do |format|
      if @event.save
        format.html { redirect_to "/events", notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, alert: "Error creating event. Make sure all required fields are correctly completed and try again." }
      end
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to "/events", notice: "Event was successfully updated." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { redirect_to "/events/#{@event.id}/edit", alert: "Error creating event. Make sure all required fields are correctly completed and try again." }
      end
    end
  end

  def destroy
    @event = Event.find(params[:id])
    if @event.delete
       redirect_to events_path,
                  notice: 'Event successfully deleted.'
    else
      redirect_to events_path,
                  alert: 'Error deleting event.'
    end
  end

  private
  def event_params
    params.require(:event)
      .permit(:title, :date, :time, :description, :location, :link, :link_text)
  end

end
