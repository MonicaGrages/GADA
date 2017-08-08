class EventsController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]
  load_and_authorize_resource  only: [:new, :create, :edit, :update, :destroy]

  def index
    @upcoming_events = Event.where('date >= ?', Date.today)
  end

end
