module Members
  class API < Grape::API
    helpers Defaults
    format :json

    get do
      authorize
      Member.all
    end

    params do
      requires :email
    end
    get :search do
      authorize
      member = Member.find_by(email: params[:email].downcase)
      return member if member && !member.expired?

      error!('Member not found', 404)
    end

    params do
      requires :first_name
      requires :last_name
      requires :email
      requires :membership_type
    end
    post do
      authorize
      member = Member.new(params).create_membership
      return member if member.valid?
      error!(member.errors&.full_messages&.first, 400)
    end
  end
end