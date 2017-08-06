class MembersController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]

  def index
  end

  def show
  end

  def new
  end

end
