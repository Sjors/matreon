import React from 'react';
import ReactDOM from 'react-dom';
import { connect } from 'react-redux';

import { NavLink as Link } from 'react-router-dom';

export default class Contribution extends React.Component {
  constructor(props, context) {
    super(props, context);

    this.state = { 
      isLoggedIn: window.layoutProps.isLoggedIn,
      isContributor: window.layoutProps.isContributor,
      contributorCount: window.layoutProps.contributorCount 
    };
  }

  render() {
    return (
      <div>
        { this.state.isContributor && 
          <p>
            You are part of { this.state.contributorCount } matrons, thanks!
          </p>
        }
        { !this.state.isContributor && 
          <p>
            Welcome, you can{' '}
            <Link to='/contribution'>
              join { this.state.contributorCount } matrons{' '}
            </Link>
            starting at 1 satoshi per month. That's just $1 per millenium!
          </p>
        }
      </div>
    );
  }
}
