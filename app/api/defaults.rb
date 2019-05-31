module Defaults
  extend Grape::API::Helpers
  extend ActiveSupport::Concern

  def authorize
    authorized = request.headers['X-Auth-Token'].present? &&
                 request.headers['X-Auth-Token'] == ENV['CHECKIN_APP_AUTH_TOKEN']
    error!('401 Unauthorized', 401) unless authorized
  end
end
