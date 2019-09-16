import React from 'react';
import axios from 'axios';

export default class SearchResult extends React.Component {
  state = { loading: false, searchParams: '', results: [] };

  renew = () => {
    window.location.href = `/events/${this.props.eventId}/renew?member_id=${this.props.result.id}`;
  }

  checkIn = () => {
    const params = { checkin: { event_id: this.props.eventId, member_id: this.props.result.id } }
    const csrf = document.querySelector("meta[name='csrf-token']").getAttribute("content");
    axios.defaults.headers.common['X-CSRF-TOKEN'] = csrf

    axios.post(`/events/${this.props.eventId}/checkins`, params, {
      headers: {
        'Content-Type': 'application/json',
      }
    })
    .then(res => {
      window.location.href = `/events/${this.props.eventId}/checkins/new?completed_checkin=true`;
    })
    .catch(() => this.setState({ loading: false, results: [] }));
  }

  onClick = () => {
    if (this.props.result.expired === true) {
      this.renew();
    } else {
      this.checkIn();
    }
  }

  buttonText = () => {
    if (this.props.result.checked_in === true) return 'Already Checked In'
    if (this.props.result.expired === true) return 'Renew Membership and Check In'
    return 'Check In'
  }

  render () {
    return (
      <button className='btn btn-small blue hoverable' onClick={this.onClick} disabled={this.props.result.checked_in}>{this.buttonText()}</button>
    )
  }
}
