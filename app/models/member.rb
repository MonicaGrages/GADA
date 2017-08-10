class Member < ApplicationRecord
  validates :email, uniqueness: true, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :membership_type, presence: true

  before_save { email.downcase! }
end
