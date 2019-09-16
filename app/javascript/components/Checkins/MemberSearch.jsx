import React from 'react';
import axios from 'axios';
import SearchResult from './SearchResult';

export default class MemberSearch extends React.Component {
  state = { loading: false, searchParams: '', results: [] };

  onChange = (e) => {
    this.state.searchParams = e.target.value.trim();
    this.submit();
  }

  submit = () => {
    this.setState({ loading: true });
    if (this.state.searchParams.length > 1) {
      axios.get(`/events/${this.props.eventId}/member_search`, { params: { member_info: this.state.searchParams } }, {
        headers: {
          'Content-Type': 'application/json',
        }
      })
      .then(res => this.setState({ loading: false, results: res.data }))
      .catch(() => this.setState({ loading: false, results: [] }));
    } else {
      this.setState({ loading: false, results: [] });
    }
  }

  render() {
    const NO_RESULTS_MESSAGE = "We couldn't find a current member matching that information. Please join by clicking the button below. See a board member if you think this is an error.";
    return (
      <div className="">
        <div className=''>
          <h5 className='header center light blue-text'>Already a member? Start typing your last name OR first name OR email address</h5>
          <div className="form-container z-depth-3">
            <input name="query" type="text" placeholder="Start typing..." onChange={this.onChange} autoComplete="off" />
            <span onClick={this.submit} className='btn btn-small hoverable'>
              Search
            </span>
          </div>
          <div className="collection">
            {this.state.results.map(result => <SearchResult key={result.id} result={result} eventId={this.props.eventId} />)}
          </div>
        </div>
        <h5 className='header center light red-text'>
          {!this.state.loading && this.state.searchParams.length > 1 && !this.state.results.length ? NO_RESULTS_MESSAGE : ''}
        </h5>
        <div>
          <a className='btn btn-large join-now-button hoverable' href={`/events/${this.props.eventId}/renew`}>Not a member yet? Join Now</a>
        </div>
      </div>
    );
  }
}
