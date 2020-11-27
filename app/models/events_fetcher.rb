class EventsFetcher
  require 'net/http'
  require 'uri'
  require 'json'

  BASE_URL = "https://www.eventbriteapi.com/v3/organizations"

  def self.events
    uri = URI.parse("#{BASE_URL}/#{ENV['EVENTBRITE_ORGANIZATION_ID']}/events/")
    uri.query = URI.encode_www_form({ time_filter: "current_future", status: "live" })

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{ENV['EVENTBRITE_API_KEY']}"
    response = http.request(request)

    JSON.parse(response.body)["events"]
  end
end
