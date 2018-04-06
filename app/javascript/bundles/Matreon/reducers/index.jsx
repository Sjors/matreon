import contributionsReducer, { $$initialState as $$contributionsState } from './contributionsReducer';
import invoicesReducer, { $$initialState as $$invoicesState } from './invoicesReducer';

export default {
  $$contributionsStore: contributionsReducer,
  $$invoicesStore: invoicesReducer
};

export const initialStates = {
  $$contributionsState,
  $$invoicesState
};
