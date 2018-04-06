import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { NavLink as Link } from 'react-router-dom';

export default class Layout extends Component {
  static propTypes = {
    children: PropTypes.object.isRequired,
  };

  constructor(props) {
    super(props);
    this.state = { isLoggedIn: window.layoutProps.isLoggedIn };
  }

  render() {
    return (
      <div>
        <nav className="navbar navbar-expand-md navbar-dark bg-dark fixed-top">
        <Link to="/"  className="navbar-brand">
          Matreon
        </Link>
        <button className="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarsExampleDefault" aria-controls="navbarsExampleDefault" aria-expanded="false" aria-label="Toggle navigation">
              <span className="navbar-toggler-icon"></span>
            </button>

            <div className="collapse navbar-collapse" id="navbarsExampleDefault">
              <ul className="navbar-nav mr-auto">
                <li className="nav-item active">
                  <Link to="/" className="nav-link">
                    Home <span className="sr-only">(current)</span>
                  </Link>
                </li>
                { this.state.isLoggedIn &&
                  <li className="nav-item">
                    <Link to="/contribution" activeClassName="active" className="nav-link">
                      My Contribution
                    </Link>
                  </li>
                }
                { this.state.isLoggedIn &&
                  <li className="nav-item">
                  <Link to="/invoices" activeClassName="active" className="nav-link">
                    Invoices
                  </Link>
                </li>
                }
                { this.state.isLoggedIn &&
                  <li className="nav-item">
                    <a className="nav-link" href="/users/sign_out" data-method="delete">Logout</a>
                  </li>
                }
                { !this.state.isLoggedIn &&
                  <li className="nav-item">
                    <a className="nav-link" href="/users/sign_in">Login</a>
                  </li>
                }
                { !this.state.isLoggedIn &&
                  <li className="nav-item">
                    <a className="nav-link" href="/users/sign_up">Register</a>
                  </li>
                }
              </ul>
            </div>
          </nav>

          <main role="main" className="container">
              {this.props.children}
          </main>
        </div>
    );
  }
}
