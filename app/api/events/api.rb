module Events
  class API < Grape::API
    helpers Defaults
    format :json
    
    get do
      authorize
      events = Event.where('date >= ?', ActiveSupport::TimeZone.new('EST').today).order('date ASC')
      events.map do |event|
        { title: event.title,
          date: event.date,
          location: event.location,
          checkins: event.members.count }
      end
    end

    route_param :id do
      get do
        authorize
        Event.find(params[:id])
      end

      namespace :checkin do
        route_param :member_id do
          post do
            authorize
            event = Event.find(params[:id])
            member = Member.find(params[:member_id])
            checkin = Checkin.where(event_id: event.id, member_id: member.id).first_or_initialize
            return { message: "You've already been checked in. Enjoy the event!" } if checkin.id
            checkin.save!
            { message: "Thanks for checking in! Enjoy the event." }
          end
        end
      end
    end
  end
end