class Event < ApplicationRecord
  validates :title, presence: true
  validates :date, presence: true
  validates :description, presence: true
  validates :location, presence: true

  before_save { time.to_time if time }

  has_many :checkins
  has_many :members, through: :checkins
end
