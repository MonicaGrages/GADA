class Member < ApplicationRecord
  before_validation :downcase_email
  after_initialize :assign_default_expiration_date

  validates :email, uniqueness: true, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :membership_type, presence: true

  attr_accessor :notices

  RECORD_SPECIFIC_FIELDS = %w(id created_at updated_at)

  def downcase_email
    email&.downcase!
  end

  def create_membership
    if @existing_member = Member.where(email: email&.downcase).first
      if @existing_member.membership_expiration_date < membership_expiration_date
        @updated_member = renew_member
      elsif @existing_member.membership_expiration_date >= membership_expiration_date
        errors[:base] << "There is already a current member with the email #{@existing_member.email}. If you need to update this member's info, go to the Admin Menu and click 'Current Members'."
      end
    else
      save_new_member
    end
    @updated_member || self
  end

  def subscribe_to_mailchimp
    mailchimp_response = MailchimpSubscriber.new(self).subscribe_member
    list_subscription_successful?(mailchimp_response[0], 'Current Members')
    list_subscription_successful?(mailchimp_response[1], 'Current and Potential Members')
  end

  def expired?
    membership_expiration_date < Date.today
  end

  def assign_default_expiration_date
    self.membership_expiration_date = membership_expiration_date || default_expiration_date
  end

  def default_expiration_date
    current_year = Time.now.year
    exp_year = Time.now.month <= 5 ? current_year : current_year + 1

    "#{exp_year}-05-31"
  end

  private

  def save_new_member
    return unless errors.empty?
    if save
      self.notices = ["New member #{first_name} #{last_name} was successfully saved."]
      subscribe_to_mailchimp
      return
    end
    errors[:base] << "There was an error adding member #{first_name} #{last_name}. " +
                     'Please make sure fields are correctly filled out and try again.'
  end

  def renew_member
    if @existing_member.update(self.serializable_hash.except(*RECORD_SPECIFIC_FIELDS))
      self.notices = ["Membership for #{first_name} #{last_name} was successfully renewed."]
      subscribe_to_mailchimp
      @existing_member
    else
      errors[:base] << "Error renewing membership for #{first_name} #{last_name}. Please make sure fields are correctly filled out and try again. Or go to update members page from admin menu."
    end
  end

  def list_subscription_successful?(response, list_type)
    if response.code != '200'
      puts response.body
      if response.body && JSON.parse(response.body) && JSON.parse(response.body)['title'] == 'Member Exists'
        self.notices << "Member already subscribed to Mailchimp #{list_type} List."
        return
      end
      return errors[:base] << "Unable to subscribe member to MailChimp #{list_type} List. Please add manually."
    end
    self.notices << "Member successfully subscribed to Mailchimp #{list_type} List."
  end
end
