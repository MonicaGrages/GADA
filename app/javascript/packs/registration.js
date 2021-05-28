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
  const rdMembershipPrice = JSON.parse(nodeToMountOn.getAttribute('data-rd-membership-price'));
  const studentMembershipPrice = JSON.parse(nodeToMountOn.getAttribute('data-student-membership-price'));
  const offerSlidingScaleMembershipPricing = JSON.parse(nodeToMountOn.getAttribute('data-offer-sliding-scale-membership-pricing'));
  const minimumSlidingScaleRdMembershipPrice = JSON.parse(nodeToMountOn.getAttribute('data-minimum-sliding-scale-rd-membership-price'));


  ReactDOM.render(
    <Registration
      clientAuthtoken={clientAuthtoken}
      rdMembershipPrice={rdMembershipPrice}
      studentMembershipPrice={studentMembershipPrice}
      offerSlidingScaleMembershipPricing={offerSlidingScaleMembershipPricing}
      minimumSlidingScaleRdMembershipPrice={minimumSlidingScaleRdMembershipPrice}
    />,
    nodeToMountOn
  );
});