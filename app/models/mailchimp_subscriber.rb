class MailchimpSubscriber
  require 'net/http'
  require 'uri'
  require 'json'

  def initialize(member)
    @member = member
  end

  def subscribe_member
    member_list_id = ENV['MAILCHIMP_MEMBER_LIST_ID']
    potential_and_member_list_id = ENV['MAILCHIMP_POTENTIAL_MEMBER_LIST_ID']
    member_list_response = post_to_mailchimp(member_list_id)
    potential_member_list_reponse = post_to_mailchimp(potential_and_member_list_id)
    [member_list_response, potential_member_list_reponse]
  end

  private

  def post_to_mailchimp(list_id)
    uri = URI.parse("https://us6.api.mailchimp.com/3.0/lists/#{list_id}/members")
    header = {'content-type': 'application/json'}
    member = member_params
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.basic_auth 'user', ENV['MAILCHIMP_API_KEY']
    request.body = member.to_json
    response = http.request(request)
  end

  def member_params
    { email_address: @member.email,
      status: 'subscribed',
      merge_fields: { FNAME: @member.first_name,
                      LNAME: @member.last_name,
                      MMERGE3: @member.membership_type } }
  end
end
