import PropTypes from 'prop-types';
import React from 'react';
import ReactDOM from 'react-dom';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import * as invoicesActionCreators from '../../actions/invoicesActionCreators';

function stateToProps(state) {
  if (state.$$invoicesStore) {
    return {
      invoices: state.$$invoicesStore.get('$$invoices'),
    };
  }
  return { };
}

class Invoice extends React.Component {
  static propTypes = {
    invoices: PropTypes.object // Absent if not logged in
  };

  constructor(props, context) {
    super(props, context);

    // TODO: do this properly
    if (!window.layoutProps.isLoggedIn) {
      window.location='/users/sign_in';
    }
  }

  componentDidMount() {
    const { invoices, dispatch } = this.props;

    this.actions = bindActionCreators(invoicesActionCreators, dispatch);

    this.actions
      .fetchInvoices()
  }

  render() {

    return (
      <div>
        <h1>Your invoices</h1>
        {this.props.invoices.map((invoice, i) =>
          <div key={i}>
            <h3>{invoice.get('created_at')}</h3>
            <ul>
              <li>{invoice.get('amount')} satoshi</li>
              {invoice.get('status') != "unpaid" && invoice.get('status') != "paid" &&
                <li>{invoice.get('status')}</li>
              }
              { invoice.get('paid_at') &&
                <li>Paid: {invoice.get('paid_at')}</li>
              }
              { !invoice.get('paid_at') && invoice.get('status') != "expired" &&
                <li><a href={invoice.get('url')} target='_blank'>Pay with Lightning</a></li>
              }
            </ul>
          </div>
        )}
      </div>
    );
  }
}

export default connect(stateToProps)(Invoice);
