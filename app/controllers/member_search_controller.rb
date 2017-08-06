class MemberSearchController < ApplicationController

  def index
    if params["/member_search/results"]
      email = member_params["email"]
      @member = Member.find_by(email: email)
      if @member
        puts @member.first_name
        @now = Time.now
        @message = "Your membership is current through #{@now}"
      else
        puts "no member with that email was found"
        @message = "Your membership is not current"
      end
      puts @message
    end
  end

  def show
    puts "show method"
    # puts params
  end


  private
  def member_params
    params.require("/member_search/results")
      .permit("email")
  end
end
