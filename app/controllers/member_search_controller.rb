class MemberSearchController < ApplicationController

  def index
    if params["/member_search/results"]
      email = member_params["email"].downcase
      @member = Member.find_by(email: email)
      now = Date.today
      if @member
        @expiration_date = @member.membership_expiration_date.strftime("%D")
        if @member.membership_expiration_date > now
          @message = "Your membership is current through #{@expiration_date}"
        else
          @message = "Your membership expired on #{@expiration_date}"
        end
      else
        puts "That email address is not associated with a current member"
        @message = "That email address is not associated with a current member"
      end
      puts @message
    end
  end

  private
  def member_params
    params.require("/member_search/results")
      .permit("email")
  end
end
