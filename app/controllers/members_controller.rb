class MembersController < ApplicationController
  before_action :authenticate_user!

  UPDATE_ERROR_MESSAGE = "Error updating member info. Please make sure all information was filled in and try again."

  def index
    @active_members = Member.where('membership_expiration_date > ?', Date.today).order('last_name ASC')
    @active_member_count = @active_members.count
    @student_member_count = @active_members.where("membership_type ilike ?", 'Student').count
    @rd_member_count = @active_members.where("membership_type ilike ?", 'RD').count
  end

  def new
    @member = Member.new
    set_years_for_form
  end

  def create
    member = Member.new(member_params)
    member.create_membership
    respond_to do |format|
      alert = member.errors&.full_messages&.join(' ')
      notice = member.notices&.join(' ')
      if notice.present?
        format.html { redirect_to "/members", alert: alert, notice: notice }
      elsif alert.present?
        format.html { redirect_to "/members/new", alert: alert, notice: notice }
      else
        format.html { redirect_to "/members/new", alert: 'Something went wrong.', notice: notice }
      end
    end
  end

  def edit
    @member = Member.find(params[:id])
    set_years_for_form
  end

  def update
    @member = Member.find(params[:id])
    respond_to do |format|
      if @member.update(member_params)
        @member.notices = ["Member information was successfully updated."]
        renew_email_subscription
        alert = @member.errors&.full_messages&.join(' ').presence
        notice = @member.notices&.join(' ').presence
        format.html { redirect_to "/members", alert: alert, notice: notice }
      else
        alert = member.errors&.full_messages&.join(' ').presence || UPDATE_ERROR_MESSAGE
        format.html { redirect_to "/members/#{@member.id}/edit", alert: alert }
      end
    end
  end

  def destroy
    @member = Member.find(params[:id])
    if @member.delete
       redirect_to members_path,
                  notice: 'Member successfully deleted.'
    else
      redirect_to members_path,
                  alert: 'Error deleting member.'
    end
  end

  private

  def member_params
    params.require(:member)
      .permit(:first_name, :last_name, :email, :membership_type, :membership_expiration_date)
  end

  def set_years_for_form
    month = Time.now.month
    year = Time.now.year
    @first_year = month <= 5 ? year : year + 1
    @second_year = month <= 5 ? year + 1 : year + 2
  end

  def renew_email_subscription
    return unless @member.membership_expiration_date && @member.membership_expiration_date_before_last_save
    if @member.membership_expiration_date > @member.membership_expiration_date_before_last_save
      @member.subscribe_to_mailchimp
    end
  end
end
