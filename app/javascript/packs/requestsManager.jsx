import request from 'axios';
import ReactOnRails from 'react-on-rails';

export default {

  /**
   * Retrieve list of entities from server using AJAX call.
   *
   * @param {String} endpoint.
   * @returns {Promise} - Result of ajax call.
   */
  fetchEntity(endpoint) {
    return request({
      method: 'GET',
      url: endpoint,
      responseType: 'json',
    });
  },

  /**
   * Update existing entity to server using AJAX call.
   *
   * @param {String} endpoint.
   * @param {Object} entity - Request body to post.
   * @returns {Promise} - Result of ajax call.
   */
  updateEntity(endpoint, entity) {
    return request({
      method: 'PUT',
      url: endpoint,
      responseType: 'json',
      headers: ReactOnRails.authenticityHeaders(),
      data: entity,
    });
  },

};
