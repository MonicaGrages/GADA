class EventsController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]
  load_and_authorize_resource  only: [:create, :edit, :update, :destroy]
end
