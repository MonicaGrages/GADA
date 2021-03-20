import 'core-js';
import React from 'react';
import ReactDOM from 'react-dom';
import Events from '../components/Events/Events'

document.addEventListener('DOMContentLoaded', () => {
  const nodeToMountOn = document.querySelector('#events');
  if (nodeToMountOn === null) {
    return;
  }

  const clientAuthtoken = nodeToMountOn.getAttribute('data-client-authtoken');
  ReactDOM.render(<Events clientAuthtoken={clientAuthtoken} />, nodeToMountOn);
});