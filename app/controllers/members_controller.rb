class MembersController < ApplicationController
  before_action :authenticate_user!

  def index
    @active_members = Member.where('membership_expiration_date > ?', Date.today)
    @active_member_count = @active_members.count
    @student_member_count = @active_members.where(membership_type: "Student").count
    @rd_member_count = @active_members.where(membership_type: "RD").count
  end

  def new
    @member = Member.new
  end


  def create
    @new_member = Member.new(member_params)
    if Member.exists?(email: @new_member.email.downcase!)
      @existing_member = Member.find_by(email: @new_member.email)
      # if trying to renew existing or expired member
      if @existing_member.membership_expiration_date < @new_member.membership_expiration_date
        respond_to do |format|
          # if successful renew
          if @existing_member.update(member_params)
            format.html { redirect_to "/members", notice: "Membership successfully renewed for #{@new_member.first_name} #{@new_member.last_name}" }
          # if fail to renew
          else
            format.html { redirect_to "/members/new", alert: "Error renewing membership for #{@new_member.first_name} #{@new_member.last_name}. Please make sure fields are correctly filled out and try again. Or go to update members page from admin menu." }
          end
        end
      # if trying to add a member that is already current
      elsif @existing_member.membership_expiration_date >= @new_member.membership_expiration_date
        respond_to do |format|
          format.html { redirect_to "/members/new", alert: "There is already a current member with the email #{@existing_member.email}. If you need to update this member's info, go to the Admin Menu and click 'Current Members'." }
        end
      end
    else
      respond_to do |format|
        if @new_member.save
          format.html { redirect_to "/members", notice: "New Member #{@new_member.first_name} #{@new_member.last_name} was successfully added" }
        else
          format.html { redirect_to "/members/new", alert: "Error adding member. Please make sure all information was filled in correctly and try again." }
        end
      end
    end
  end



  def edit
    @member = Member.find(params[:id])
  end

  def update
    puts "update method in controller"
    @member = Member.find(params[:id])
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to "/members", notice: "Member #{@member.first_name} #{@member.last_name} was successfully updated" }
      else
        format.html { redirect_to "/members/#{@member.id}/edit", alert: "Error updating member info. Please make sure all information was filled in correctly and try again." }
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

end
