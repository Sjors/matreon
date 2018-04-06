import PropTypes from 'prop-types';
import React from 'react';
import { connect } from 'react-redux';

function stateToProps(state) {
  // Which part of the Redux global state does our component want to receive as props?
  if (state.$$contributionsStore) {
    return {
      contribution: state.$$contributionsStore.get('$$contribution')
    };
  }
  return { };
}

class Contribution extends React.Component {
  static propTypes = {
    contribution: PropTypes.object.isRequired,
  };
  render() {
    const { contribution } = this.props;

    return (
      <div>
        <h1>Your contribution</h1>
        <p>
          We will email you an invoice each month, unless the amount is zero. 
        </p>
        <pre>{contribution.get('amount')}</pre>
      </div>
    );
  }
}

export default connect(stateToProps)(Contribution);
