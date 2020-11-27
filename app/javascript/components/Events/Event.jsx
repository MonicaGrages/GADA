import React from 'react';

const Event = ({event}) => {
  return (
    <div className="form-container z-depth-3">
      <h4 className="header teal-text">{event.name}</h4>
      <h5 className="header light">{event.date}</h5>
      <h5 className="event-time header light">{event.time}</h5>
      <h5 className="header light">{event.description}</h5>
      <h6><a href={event.url}>Find out more and RSVP through Eventbrite</a></h6>
    </div>
  )
};

export default Event;