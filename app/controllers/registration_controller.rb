class RegistrationController < ApplicationController
  before_action :authenticate_user!, :except => [:discounted_membership, :success, :index]

  def discounted_membership
    month = Time.now.month
    year = Time.now.year
    @first_year = month <= 5 ? year : year + 1
    @second_year = month <= 5 ? year + 1 : year + 2
    settings = Setting.first
    @offering_discounted_membership = settings&.offer_discounted_membership
    if @offering_discounted_membership
      render 'discounted_membership'
    else
      redirect_to registration_path
    end
  end

  def success
  end

  def about_discounted_membership
    settings = Setting.first
    @offering_discounted_membership = settings&.offer_discounted_membership
  end
end
