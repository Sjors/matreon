/* eslint new-cap: 0 */

import Immutable from 'immutable';

import * as actionTypes from '../constants/invoicesConstants';

export const $$initialState = Immutable.fromJS({
  $$invoices: [],
  isFetching: false
});

export default function invoicesReducer($$state = $$initialState, action = null) {
  const {
    type, invoices, error, locale,
  } = action;

  switch (type) {
    case actionTypes.FETCH_INVOICES_SUCCESS: {
      return $$state.merge({
        $$invoices: invoices,
        fetchInvoicesError: null,
        isFetching: false,
      });
    }

    case actionTypes.FETCH_INVOICES_FAILURE: {
      return $$state.merge({
        fetchInvoicesError: error,
        isFetching: false,
      });
    }

    case actionTypes.SET_IS_FETCHING_INVOICES: {
      return $$state.merge({
        isFetching: true,
      });
    }

    default: {
      return $$state;
    }
  }
}
