class Checkin < ApplicationRecord
  belongs_to :event
  belongs_to :member
  validates :member_id, uniqueness: { scope: :event_id,
                                      message: 'has already checked in for this event' }
end
