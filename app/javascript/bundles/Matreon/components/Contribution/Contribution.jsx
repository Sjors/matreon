import PropTypes from 'prop-types';
import React from 'react';
import ReactDOM from 'react-dom';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import * as contributionActionCreators from '../../actions/contributionsActionCreators';

import { 
  Form,
  FormGroup,
  Input,
  Col,
  Button
} from 'reactstrap';

function stateToProps(state) {
  if (state.$$contributionsStore) {
    return {
      contribution: state.$$contributionsStore.get('$$contribution'),
      isSaving: state.$$contributionsStore.get('isSaving'),
      isDirty: state.$$contributionsStore.get('isDirty')
    };
  }
  return { };
}

class Contribution extends React.Component {
  static propTypes = {
    contribution: PropTypes.object, // Absent if not logged in
    isSaving: PropTypes.bool.isRequired,
    isDirty: PropTypes.bool.isRequired
  };

  constructor(props, context) {
    super(props, context);

    // TODO: do this properly
    if (!window.layoutProps.isLoggedIn) {
      window.location='/users/sign_in';
    }
  }

  updateAmount(e) {
    this.actions
      .updateContribution({amount: parseInt(e.target.value)})
  }

  handleSubmit(e) {
    e.preventDefault();
    this.actions
      .submitContribution(this.props.contribution)
  }

  render() {
    const { contribution, dispatch } = this.props;

    this.actions = bindActionCreators(contributionActionCreators, dispatch);

    return (
      <div>
        <h1>Your contribution</h1>
        <p>
          We will email you an invoice each month, unless the amount is zero. 
        </p>
        <Form horizontal="true" className="contributionForm form-horizontal" onSubmit={this.handleSubmit.bind(this)}>
        <FormGroup>
          <Col sm={3}>
            Amount (satoshi per month)
          </Col>
          <Col sm={3}>
            <Input
              type="number"
              ref="horizontalAmountNode"
              value={this.props.contribution.get('amount')}
              onChange={this.updateAmount.bind(this)}
              disabled={this.props.isSaving}
            />
          </Col>
        </FormGroup>
        <FormGroup>
          <Col sm={5}>
            <Button
              type="submit"
              className="btn btn-primary"
              disabled={this.props.isSaving || !this.props.isDirty}
            >
              {this.props.isSaving ? `Saving...` : `Submit`}
            </Button>
          </Col>
        </FormGroup>
        </Form>
      </div>
    );
  }
}

export default connect(stateToProps)(Contribution);
