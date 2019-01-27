class MemberMailer < ApplicationMailer
  default from: 'webmaster@eatrightatlanta.org'

  def welcome_email
    @member = params[:member]
    mail(to: @member.email, subject: 'Thank you for joining GADA')
  end
end
