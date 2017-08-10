class Member < ApplicationRecord
  validates :email, uniqueness: true, presence: true

  before_save { email.downcase! }
end
