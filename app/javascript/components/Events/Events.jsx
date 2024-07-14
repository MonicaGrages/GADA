import React, { useEffect, useState } from 'react';
import { apiRequests } from 'helpers/apiRequests';
import Event from "./Event";

const Events = ({ clientAuthtoken }) => {
  const [events, setEvents] = useState([]);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);

  const apiClient = apiRequests(clientAuthtoken);

  useEffect(() => {
    const fetchEvents = async () => {
      try {
        const response = await apiClient.get(`/v1/events`);

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
                <h4 className="header light center">We have lots of upcoming events, but details are not available yet. Come back soon to find out more!</h4>
              }
            </>
          }
          <h6 className="container light text-center">Our team sometimes shares photos taken at our events on social media. If
            you plan to attend events but would not like any photos of you to be shared, please email
            gadainfo@gadaatl.org.
          </h6>
        </>
      }
    </main>
  );
};

export default Events;
