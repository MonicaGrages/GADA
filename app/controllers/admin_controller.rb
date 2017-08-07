class AdminController < ApplicationController
  before_action :authenticate_user!

  def index
    @active_members = Member.where('membership_expiration_date > ?', Date.today)
    @active_member_count = @active_members.count
  end

end
