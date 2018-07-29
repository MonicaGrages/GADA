class WebhooksController < ApplicationController
  protect_from_forgery :except => [:create]

  def create
    response = validate_IPN_notification(request.raw_post)
    case response
    when "VERIFIED"
      PaymentTransaction.create(payload: params)
      create_membership if verify_payment_details
    when "INVALID"
      PaymentTransaction.create(payload: params)
      create_membership if verify_payment_details
    else
      PaymentTransaction.create(payload: params)
    end
    head :ok
  end

  protected

  def validate_IPN_notification(raw)
    uri = URI.parse('https://ipnpb.sandbox.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 60
    http.read_timeout = 60
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.use_ssl = true
    response = http.post(uri.request_uri, raw,
                         'Content-Length' => "#{raw.size}",
                         'User-Agent' => "Ruby-IPN-VerificationScript"
                       ).body
  end

  def verify_payment_details
    puts "verifying params: "
    puts params.to_unsafe_h
    payment_completed = params['payment_status'] == 'Completed'
    puts "payment completed is #{payment_completed}"
    new_transaction = PaymentTransaction.where("payload ->> 'txn_id' = ?", params['txn_id']).blank?
    puts "new_transaction is #{new_transaction}"
    receiver_matches = params['receiver_email'].downcase == 'treasurer@eatrightatlanta.org'
    puts "receiver_matches is #{receiver_matches}"
    payment_completed && new_transaction && receiver_matches
  end

  def create_membership
    current_year = Time.now.year
    exp_year = Time.now.month <= 5 ? current_year : current_year + 1
    Member.create(first_name: params['first_name'],
                  last_name: params['last_name'],
                  email: params['payer_email'],
                  membership_expiration_date: "#{exp_year}-05-31",
                  membership_type: params['item_name'].downcase.includes?('student') ? 'Student' : 'RD')
  end
end
