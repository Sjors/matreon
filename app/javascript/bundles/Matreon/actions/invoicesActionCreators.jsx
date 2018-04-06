import requestsManager from '../../../packs/requestsManager';
import * as actionTypes from '../constants/invoicesConstants';

export function setIsFetching() {
  return {
    type: actionTypes.SET_IS_FETCHING_INVOICES,
  };
}

export function fetchInvoicesSuccess(data) {
  return {
    type: actionTypes.FETCH_INVOICES_SUCCESS,
    invoices: data.invoices,
  };
}

export function fetchInvoicesFailure(error) {
  return {
    type: actionTypes.FETCH_INVOICES_FAILURE,
    error,
  };
}

export function fetchInvoices() {
  return (dispatch) => {
    dispatch(setIsFetching());
    return (
      requestsManager
        .fetchEntity('invoices.json')
        .then(res => dispatch(fetchInvoicesSuccess(res.data)))
        .catch(error => dispatch(fetchInvoicesFailure(error)))
    );
  };
}
