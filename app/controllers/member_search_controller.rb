class MemberSearchController < ApplicationController

  def index
    if params["/member_search/results"]
      email = member_params["email"]
      @member = Member.find_by(email: email)
      now = Date.today
      if @member.membership_expiration_date > now
        puts "expiration date is greater than now"
        puts @member.first_name
        month = now.month
        puts month
        if month <= 5
          expiration_year = now.year
        elsif month >5
          expiration_year = now.year + 1
        end

        @message = "Your membership is current through May 31, #{expiration_year}"
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
