module Members
  class API < Grape::API
    helpers Defaults
    format :json

    get do
      authorize
      members = Member.all
    end

    params do
      requires :first_name
      requires :last_name
      requires :email
      requires :membership_type
      requires :membership_expiration_date
    end
    post do
      authorize
      member = Member.new(params)
      member.create_membership
      return member if member.valid?
      error!(member.errors&.full_messages&.first, 400)
    end
  end
end