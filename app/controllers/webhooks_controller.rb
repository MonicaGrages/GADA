class WebhooksController < ApplicationController
  protect_from_forgery :except => [:create]
  def create
    response = validate_IPN_notification(request.raw_post)
    puts "The response was #{response}."
    case response
    when "VERIFIED"
      PaymentTransaction.create(payload: request)
      # check that paymentStatus=Completed
      # check that txnId has not been previously processed
      # check that receiverEmail is your Primary PayPal email
      # check that paymentAmount/paymentCurrency are correct
      # process payment
    when "INVALID"
      puts "request is: "
      puts request
      puts "-------------------------------------------------"
      puts "request.to_s is: "
      puts request.to_s
      puts "-------------------------------------------------"
      puts "request.to_json is: "
      puts request.to_json
      puts "-------------------------------------------------"
      puts "params is: "
      puts params
      PaymentTransaction.create(payload: request)
      # log for investigation
    else
      # error
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
end
