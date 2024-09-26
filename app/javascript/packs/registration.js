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
  const retiredMembershipPrice = JSON.parse(nodeToMountOn.getAttribute('data-retired-membership-price'));
  const dtrMembershipPrice = JSON.parse(nodeToMountOn.getAttribute('data-dtr-membership-price'));
  const subscriberMembershipPrice = JSON.parse(nodeToMountOn.getAttribute('data-subscriber-membership-price'));
  const offerSlidingScaleMembershipPricing = JSON.parse(nodeToMountOn.getAttribute('data-offer-sliding-scale-membership-pricing'));
  const minimumSlidingScaleRdMembershipPrice = JSON.parse(nodeToMountOn.getAttribute('data-minimum-sliding-scale-rd-membership-price'));
  const rdMembershipDiscount = JSON.parse(nodeToMountOn.getAttribute('data-rd-membership-discount'))
  const studentMembershipDiscount = JSON.parse(nodeToMountOn.getAttribute('data-student-membership-discount'))
  const offerStudentSponsorship = JSON.parse(nodeToMountOn.getAttribute('data-offer-student-sponsorship'))

  ReactDOM.render(
    <Registration
      clientAuthtoken={clientAuthtoken}
      offerSlidingScaleMembershipPricing={offerSlidingScaleMembershipPricing}
      minimumSlidingScaleRdMembershipPrice={minimumSlidingScaleRdMembershipPrice}
      rdMembershipDiscount={rdMembershipDiscount}
      studentMembershipDiscount={studentMembershipDiscount}
      offerStudentSponsorship={offerStudentSponsorship}
      membershipPrices={{
        rd: rdMembershipPrice,
        student: studentMembershipPrice,
        dtr: dtrMembershipPrice,
        retired: retiredMembershipPrice,
        subscriber: subscriberMembershipPrice,
      }}
    />,
    nodeToMountOn
  );
});
