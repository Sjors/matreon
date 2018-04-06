import {  applyMiddleware, compose, combineReducers, createStore } from 'redux';
import { routerReducer } from 'react-router-redux';
import thunkMiddleware from 'redux-thunk';

import reducers, { initialStates } from '../reducers';

export default (props) => {
  const { $$contributionsState } = initialStates;
  const initialState = {
    $$contributionsStore: $$contributionsState.merge({
      $$contribution: props.contribution,
    })
  };

  // https://github.com/reactjs/react-router-redux
  const reducer = combineReducers({
    ...reducers,
    routing: routerReducer,
  });

  const finalCreateStore = compose(
    applyMiddleware(thunkMiddleware),
  )(createStore);

  return finalCreateStore(reducer, initialState, window.__REDUX_DEVTOOLS_EXTENSION__ && window.__REDUX_DEVTOOLS_EXTENSION__());
};
