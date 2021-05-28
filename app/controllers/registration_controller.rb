class RegistrationController < ApplicationController
  before_action :authenticate_user!, :except => [:discounted_membership, :success, :index]

  def index
    redirect_to discounted_membership_path if offering_discounted_membership?
  end

  def discounted_membership
    month = Time.now.month
    year = Time.now.year
    @first_year = month <= 5 ? year : year + 1
    @second_year = month <= 5 ? year + 1 : year + 2
    if offering_discounted_membership?
      render 'discounted_membership'
    else
      redirect_to registration_path
    end
  end

  def success
  end

  def about_discounted_membership
    offering_discounted_membership?
  end

  def offering_discounted_membership?
    settings = Setting.instance
    @offering_discounted_membership = settings&.offer_discounted_membership
  end
end
