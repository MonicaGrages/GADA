class AnnouncementsController < ApplicationController
  before_action :authenticate_user!, :except => [:show, :index]
  load_and_authorize_resource  only: [:new, :create, :edit, :update, :destroy]

  def index
    @announcements = Announcement.all.order('created_at DESC')
  end

  def show
    redirect_to announcements_path
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.new(announcement_params)
    respond_to do |format|
      if @announcement.save
        format.html { redirect_to "/announcements", notice: "Announcement was successfully created." }
      else
        format.html { render :new, alert: "Error creating announcement. Make sure all required fields are correctly completed and try again." }
      end
    end
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def update
    @announcement = Announcement.find(params[:id])
    respond_to do |format|
      if @announcement.update(announcement_params)
        format.html { redirect_to "/announcements", notice: "Announcement was successfully updated." }
      else
        format.html { redirect_to "/announcements/#{@announcement.id}/edit", alert: "Error updating announcement. Make sure all required fields are correctly completed and try again." }
      end
    end
  end

  def destroy
    @announcement = Announcement.find(params[:id])
    if @announcement.delete
       redirect_to announcements_path,
                  notice: 'Announcement successfully deleted.'
    else
      redirect_to announcements_path,
                  alert: 'Error deleting announcement.'
    end
  end

  private

  def announcement_params
    params.require(:announcement)
      .permit(:title, :content)
  end
end
