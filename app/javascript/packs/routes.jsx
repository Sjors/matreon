import React from 'react';
import { Route, Switch } from 'react-router-dom';
import Layout from './layout/Layout';
import Contribution from '../bundles/Matreon/components/Contribution/Contribution';

export default (
  <Layout>
    <Switch>
      <Route
        path="/contribution"
        component={Contribution}
        exact
      />
    </Switch>
  </Layout>
);
