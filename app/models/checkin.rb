class Checkin < ApplicationRecord
  belongs_to :event
  validates :member_id, uniqueness: { scope: :event_id,
                                      message: 'has already checked in for this event'} ,
                        allow_blank: true
end
