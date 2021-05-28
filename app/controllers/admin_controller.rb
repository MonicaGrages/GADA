class AdminController < ApplicationController
  before_action :authenticate_user!

  def index
    @offering_discounted_membership = Setting.first&.offer_discounted_membership
  end

  def update_settings
    settings = Setting.instance
    @offering_discounted_membership = settings&.offer_discounted_membership
    if settings
      respond_to do |format|
        if settings.update(offer_discounted_membership: !settings.offer_discounted_membership)
          format.html { redirect_to about_discounted_membership_path, notice: "The discounted membership page is now #{settings&.offer_discounted_membership ? 'live' : 'off'}." }
        else
          format.html { redirect_to about_discounted_membership_path, alert: "Something went wrong" }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to request.referrer, alert: 'Something went wrong' }
      end
    end
  end
end
