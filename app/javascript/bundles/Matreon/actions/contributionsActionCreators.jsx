import requestsManager from '../../../packs/requestsManager';
import * as actionTypes from '../constants/contributionsConstants';

export function setIsFetching() {
  return {
    type: actionTypes.SET_IS_FETCHING_CONTRIBUTION,
  };
}

export function updateContribution(contribution) {
  return {
    type: actionTypes.UPDATE_CONTRIBUTION,
    contribution,
  };
}

export function setIsSaving() {
  return {
    type: actionTypes.SET_IS_SAVING,
  };
}

export function fetchContributionSuccess(data) {
  return {
    type: actionTypes.FETCH_CONTRIBUTION_SUCCESS,
    contribution: data.contribution,
  };
}

export function fetchContributionFailure(error) {
  return {
    type: actionTypes.FETCH_CONTRIBUTION_FAILURE,
    error,
  };
}

export function submitContributionSuccess(contribution) {
  return {
    type: actionTypes.SUBMIT_CONTRIBUTION_SUCCESS,
    contribution,
  };
}

export function submitContributionFailure(error) {
  return {
    type: actionTypes.SUBMIT_CONTRIBUTION_FAILURE,
    error,
  };
}

export function fetchContribution() {
  return (dispatch) => {
    dispatch(setIsFetching());
    return (
      requestsManager
        .fetchEntity('contribution.json')
        .then(res => dispatch(fetchContributionSuccess(res.data)))
        .catch(error => dispatch(fetchContributionFailure(error)))
    );
  };
}

export function submitContribution(contribution) {
  return (dispatch) => {
    dispatch(setIsSaving());
    return (
      requestsManager
        .updateEntity('contribution.json', { contribution })
        .then(res => dispatch(submitContributionSuccess(res.data)))
        .catch(error => dispatch(submitContributionFailure(error)))
    );
  };
}
