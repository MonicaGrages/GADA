class Member < ApplicationRecord
  validates :email, uniqueness: true, presence: true
end
