class EventsController < ApplicationController
  load_and_authorize_resource  only: [:create, :edit, :update, :destroy]
end
