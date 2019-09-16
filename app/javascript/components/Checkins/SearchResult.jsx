import React from 'react';
import CheckinButton from './SearchResult/CheckinButton';

export default class SearchResult extends React.PureComponent {
  render () {
    const result = this.props.result;

    return (
      <div className="collection-item black-text">
        <span className="">{result.first_name} {result.last_name} - {result.email}   </span>
        <CheckinButton key={result.id} result={result} eventId={this.props.eventId} />
      </div>
    )
  }
}
