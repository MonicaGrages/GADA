class WebhooksController < ApplicationController
  PAYPAL_RECEIVER_EMAIL = "treasurer@eatrightatlanta.org"
  RECOGNIZED_NOTIFICATION_STATUSES = %w[VERIFIED INVALID].freeze

  protect_from_forgery except: :create

  def create
    response = validate_IPN_notification(request.raw_post)

    transaction_status = RECOGNIZED_NOTIFICATION_STATUSES.include?(response) ? response.downcase : "other"
    if payment_completed? && new_notification?(transaction_status)
      PaymentTransaction.create(payload: params, transaction_status: transaction_status)
      create_membership if transaction_status == "verified" && receiver_matches?
    end

    head :ok
  end

  protected

  def validate_IPN_notification(raw_response)
    uri = URI.parse('https://ipnpb.paypal.com/cgi-bin/webscr?cmd=_notify-validate')
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 60
    http.read_timeout = 60
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.use_ssl = true
    response = http.post(
      uri.request_uri,
      raw_response,
      'Content-Length' => "#{raw_response.size}",
      'User-Agent' => "Ruby-IPN-VerificationScript"
    )
    response.body
  end

  def new_notification?(transaction_status)
    PaymentTransaction.where(transaction_status: transaction_status)
                      .where("payload ->> 'txn_id' = ?", params['txn_id'])
                      .blank?
  end

  def payment_completed?
    params[:payment_status] == 'Completed'
  end


  def receiver_matches?
    params[:receiver_email].downcase == PAYPAL_RECEIVER_EMAIL
  end

  def create_membership
    current_year = Time.zone.now.year
    exp_year = Time.zone.now.month < 5 ? current_year : current_year + 1
    membership_type = params[:item_name]&.downcase&.include?('student') ? 'Student' : 'RD'
    new_member = Member.new(first_name: params[:first_name],
                            last_name: params[:last_name],
                            email: params[:payer_email],
                            membership_expiration_date: "#{exp_year}-08-31",
                            membership_type: membership_type)
    new_member.create_membership
  end
end
