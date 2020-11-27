module V1
  class EventsController < ApplicationController
    before_action :authenticate_user!, :except => [:index]

    def index
      events = EventsFetcher.events

      render json: events.map { |event| EventSerializer.new(event).as_json }
    end
  end
end
