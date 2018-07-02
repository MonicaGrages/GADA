class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def payment_handler
    if params
      PaymentTransaction.create(payload: params)
    end
  end
end
