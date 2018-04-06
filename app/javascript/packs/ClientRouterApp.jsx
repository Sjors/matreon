import React from 'react';
import ReactOnRails from 'react-on-rails';
import { BrowserRouter } from 'react-router-dom';
import routes from './routes';
import PropTypes from 'prop-types'

export default (_props, _railsContext) => {
  // Don't know how to pass these props along:
  window.layoutProps = _props.layout;
  return (
    <BrowserRouter>
      {routes}
    </BrowserRouter>
  );
};
