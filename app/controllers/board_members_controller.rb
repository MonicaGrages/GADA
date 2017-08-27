class BoardMembersController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]
  load_and_authorize_resource  only: [:new, :create, :edit, :update, :destroy]

  def index
    @board_members = BoardMember.all.order(:order)
  end

  def new
    @board_member = BoardMember.new
  end

  def create
    @board_member = BoardMember.new(board_member_params)
    respond_to do |format|
      if @board_member.save
        format.html { redirect_to "/board_members", notice: "Board member #{@board_member.name} was successfully created." }
      else
        format.html { render :new, alert: "Error adding board member. Make sure all required fields are correctly completed and try again." }
      end
    end
  end

  def edit
    @board_member = BoardMember.find(params[:id])
  end

  def update
    @board_member = BoardMember.find(params[:id])
    respond_to do |format|
      if @board_member.update(board_member_params)
        format.html { redirect_to "/board_members", notice: "Board member info was successfully updated." }
        format.json { render :show, status: :created, location: @board_member }
      else
        format.html { redirect_to "/board_members/#{@board_member.id}/edit", alert: "Error updating board member. Make sure all required fields are correctly completed and try again." }
      end
    end
  end

  def destroy
    @board_member = BoardMember.find(params[:id])
    if @board_member.delete
       redirect_to board_members_path,
                  notice: 'Board member successfully deleted.'
    else
      redirect_to board_members_path,
                  alert: 'Error deleting board member.'
    end
  end

  private
  def board_member_params
    params.require(:board_member)
      .permit(:name, :position, :description, :photo)
  end

end
