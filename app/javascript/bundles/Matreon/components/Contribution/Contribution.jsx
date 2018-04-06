import PropTypes from 'prop-types';
import React from 'react';

export default class Contribution extends React.Component {
  render() {
    return (
      <div>
        <h1>Your contribution</h1>
        <p>
          We will email you an invoice each month, unless the amount is zero. 
        </p>
      </div>
    );
  }
}
