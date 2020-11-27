class EventSerializer
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def as_json
    {
      name: event.dig("name", "text"),
      description: event.dig("description", "text"),
      url: "#{event.dig("url")}?aff=gadawebsite",
      date: DateTime.parse(event.dig("start", "local")).strftime("%A %B %e, %Y"),
      time: DateTime.parse(event.dig("start", "local")).strftime("%l:%M %p")
    }
  end
end
