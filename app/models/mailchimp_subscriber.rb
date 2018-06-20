class MailchimpSubscriber
  require 'net/http'
  require 'uri'
  require 'json'

  def initialize(member)
    @member = member
  end

  def subscribe_member
    uri = URI.parse('https://us6.api.mailchimp.com/3.0/lists/76da82af3c/members')
    header = {'content-type': 'application/json'}
    member = member_params
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.basic_auth 'user', ENV['MAILCHIMP_API_KEY']
    request.body = member.to_json
    response = http.request(request)
  end

  private

  def member_params
    { email_address: @member.email,
      status: 'subscribed',
      merge_fields: { FNAME: @member.first_name,
                      LNAME: @member.last_name,
                      MMERGE3: @member.membership_type } }
  end
end