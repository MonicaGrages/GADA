import 'core-js';
import React from 'react';
import ReactDOM from 'react-dom';
import Registration from '../components/Registration/Registration'

document.addEventListener('DOMContentLoaded', () => {
  const nodeToMountOn = document.querySelector('#registration-form');
  if (nodeToMountOn === null) {
    return;
  }

  const clientAuthtoken = nodeToMountOn.getAttribute('data-client-authtoken');
  ReactDOM.render(<Registration clientAuthtoken={clientAuthtoken} />, nodeToMountOn);
});