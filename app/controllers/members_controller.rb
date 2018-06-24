class MembersController < ApplicationController
  before_action :authenticate_user!

  def index
    @active_members = Member.where('membership_expiration_date > ?', Date.today).order('last_name ASC')
    @active_member_count = @active_members.count
    @student_member_count = @active_members.where(membership_type: "Student").count
    @rd_member_count = @active_members.where(membership_type: "RD").count
  end

  def new
    @member = Member.new
    month = Time.now.month
    year = Time.now.year
    @first_year = month <= 5 ? year : year + 1
    @second_year = month <= 5 ? year + 1 : year + 2
  end

  def create
    @new_member = Member.new(member_params)
    if @existing_member = Member.where(email: @new_member.email.downcase).first
      if @existing_member.membership_expiration_date < @new_member.membership_expiration_date
        renew_member
      elsif @existing_member.membership_expiration_date >= @new_member.membership_expiration_date
        respond_to do |format|
          alert = "There is already a current member with the email #{@existing_member.email}. If you need to update this member's info, go to the Admin Menu and click 'Current Members'."
          format.html { redirect_to "/members/new", alert: alert }
        end
      end
    else
      save_new_member
    end
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to "/members", notice: "Member #{@member.first_name} #{@member.last_name} was successfully updated" }
      else
        alert = "Error updating member info. Please make sure all information was filled in correctly and try again."
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

  def save_new_member
    respond_to do |format|
      if @new_member.save
        notice = "New Member #{@new_member.first_name} #{@new_member.last_name} was successfully added."
        mailchimp_response = MailchimpSubscriber.new(@new_member).subscribe_member
        if mailchimp_response.code == '200'
          notice += '<br>Member successfully subscribed to MailChimp.'
        else
          alert = 'Unable to subscribe member to MailChimp. Please add manually.'
        end
        format.html { redirect_to "/members", notice: notice, alert: alert }
      else
        format.html { redirect_to "/members/new", alert: "Error adding member. Please make sure all information was filled in correctly and try again." }
      end
    end
  end

  def renew_member
    respond_to do |format|
      if @existing_member.update(member_params)
        notice = "Membership successfully renewed for #{@new_member.first_name} #{@new_member.last_name}"
        mailchimp_response = MailchimpSubscriber.new(@new_member).subscribe_member
        if mailchimp_response.code == '200'
          notice += '<br>Member successfully subscribed to MailChimp.'
        else
          alert = 'Unable to subscribe member to MailChimp. Please add manually.'
        end
        format.html { redirect_to "/members", notice: notice, alert: alert }
      else
        format.html { redirect_to "/members/new", alert: "Error renewing membership for #{@new_member.first_name} #{@new_member.last_name}. Please make sure fields are correctly filled out and try again. Or go to update members page from admin menu." }
      end
    end
  end
end
