import React, { useEffect, useState } from 'react';
import axios from 'axios';
import Event from "./Event";

const Events = ({ clientAuthtoken }) => {
  const [events, setEvents] = useState([]);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);
  const csrf = document.querySelector("meta[name='csrf-token']").getAttribute("content");
  axios.defaults.headers.common['X-CSRF-TOKEN'] = csrf;
  axios.defaults.headers.common['Content-Type'] = 'application/json';
  axios.defaults.headers.common['X-Auth-Token'] = clientAuthtoken;

  useEffect(() => {
    const fetchEvents = async () => {
      try {
        const response = await axios.get(`/v1/events`);

        if (response.status === 200) {
          setEvents(response.data);
          setLoading(false);
        } else {
          setError("Something went wrong loading event details. Please try again.");
          setLoading(false);
        }
      } catch {
        setError("Something went wrong loading event details. Please try again.")
        setLoading(false);
      }
    };

    fetchEvents();
  }, []);

  return (
    <main className='events-main container'>
      <h2 className="header center orange-text">Upcoming GADA Events</h2>

      {loading ?
        <h5>Loading...</h5> :
        <>
          {events.length > 0 ?
            events.map(event => {
              return <Event event={event} key={event.name}/>
            }) :
            <>
              {error ?
                <h5>{error}</h5> :
                <h4 class="header light center">We have lots of upcoming events, but details are not available yet. Come back soon to find out more!</h4>
              }
            </>
          }
        </>
      }
    </main>
  );
};

export default Events;