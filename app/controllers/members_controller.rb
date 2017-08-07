class MembersController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
  end

  def new
    @member = Member.new
  end

  def create
    @new_member = Member.new(member_params)
    if Member.exists?(email: @new_member.email)
      @existing_member = Member.find_by(email: @new_member.email)
      # if admin user entered a new expiration date that is after the member's current expiration date
      if @existing_member.membership_expiration_date < @new_member.membership_expiration_date
        if @existing_member.update(member_params)
          respond_to do |format|
            format.html { redirect_to "/admin/menu", notice: "Membership successfully renewed for #{@existing_member.first_name} #{@existing_member.last_name}." }
          end
        end
      # if trying to add a member that is already current
      elsif @existing_member.membership_expiration_date >= @new_member.membership_expiration_date
        respond_to do |format|
          puts "There is already a current member with the email #{@existing_member.email}. If you want to update this member's information, go back to the Admin menu and click 'Update Existing Member'."
          format.html { redirect_to "/members/new", alert: "There is already a current member with the email #{@existing_member.email}. If you need to update this member's information, go back to the Admin Menu and click 'Update Existing Member'." }
        end
      end
    else
      respond_to do |format|
        if @new_member.save
          format.html { redirect_to "/admin/menu", notice: "New Member #{@new_member.first_name} #{@new_member.last_name} was successfully added" }
        else
          format.html { redirect_to "/members/new", alert: "Error adding member. Please make sure all information was filled in correctly and try again." }
        end
      end
    end
  end

  private
  def member_params
    params.require(:member)
      .permit(:first_name, :last_name, :email, :membership_type, :membership_expiration_date)
  end

end
