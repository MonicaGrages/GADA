class Member < ApplicationRecord
  before_validation :downcase_email

  validates :email, uniqueness: true, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :membership_type, presence: true

  def downcase_email
    email.downcase!
  end
end
