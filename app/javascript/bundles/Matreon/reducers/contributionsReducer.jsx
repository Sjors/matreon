/* eslint new-cap: 0 */

import Immutable from 'immutable';

import * as actionTypes from '../constants/contributionsConstants';

export const $$initialState = Immutable.fromJS({
  $$contribution: {},
  fetchContributionError: null,
  submitContributionError: null,
  isFetching: false,
  isSaving: false,
  isDirty: false
});

export default function contributionReducer($$state = $$initialState, action = null) {
  const {
    type, contribution, error, locale,
  } = action;

  switch (type) {
    case actionTypes.FETCH_CONTRIBUTION_SUCCESS: {
      return $$state.merge({
        $$contribution: contribution,
        fetchContributionError: null,
        isFetching: false,
      });
    }

    case actionTypes.UPDATE_CONTRIBUTION: {
      return $$state.merge({
        $$contribution: contribution,
        isDirty: true // Naive approach
      });
    }

    case actionTypes.FETCH_CONTRIBUTION_FAILURE: {
      return $$state.merge({
        fetchContributionError: error,
        isFetching: false,
      });
    }

    case actionTypes.SUBMIT_CONTRIBUTION_SUCCESS: {
      return $$state.withMutations(state => (
        state
          .updateIn(
            ['$$contribution'],
            $$contribution => Immutable.fromJS(contribution),
          )
          .merge({
            submitContributionError: null,
            isSaving: false,
            isDirty: false
          })
      ));
    }

    case actionTypes.SUBMIT_CONTRIBUTION_FAILURE: {
      return $$state.merge({
        submitContributionError: error,
        isSaving: false,
      });
    }

    case actionTypes.SET_IS_FETCHING: {
      return $$state.merge({
        isFetching: true,
      });
    }

    case actionTypes.SET_IS_SAVING: {
      return $$state.merge({
        isSaving: true,
      });
    }

    default: {
      return $$state;
    }
  }
}
