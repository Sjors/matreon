import React from 'react';
import { createStore } from 'redux';
import { Provider } from 'react-redux';
import ReactOnRails from 'react-on-rails';
import { BrowserRouter } from 'react-router-dom';
import routes from './routes';
import PropTypes from 'prop-types'

export default (_props, _railsContext) => {
  const store = ReactOnRails.getStore('contributionsStore');

  // Don't know how to pass these props along:
  window.layoutProps = _props.layout;

  return (
    <Provider store={store}>
      <BrowserRouter>
        {routes}
      </BrowserRouter>
    </Provider>
  );
};
