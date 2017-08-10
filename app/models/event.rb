class Event < ApplicationRecord

  before_save { time.to_time }

end
