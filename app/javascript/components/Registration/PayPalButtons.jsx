import React, { useState } from 'react';
import ReactDOM from 'react-dom';

import CircularProgress from '@material-ui/core/CircularProgress';

const PayPalButtons = ({
  membershipType,
  price,
  setPaymentCompleted,
  processingPayment,
  setProcessingPayment,
  saveMembership
}) => {
  const [error, setError] = useState(null);

  const PaymentButtons = window.paypal.Buttons.driver('react', { React, ReactDOM });

  const createOrder = (data, actions) => {
    const priceWithFees = (price + .40 + price * 0.029).toFixed(2);
    return actions.order.create({
      purchase_units: [
        {
          description: membershipType,
          amount: {
            currency_code: 'USD',
            value: priceWithFees,
          },
        },
      ],
    });
  };

  const onApprove = async (data, actions) => {
    setProcessingPayment(true);
    const order = await actions.order.capture();
    const response = await saveMembership(order);

    setProcessingPayment(false);

    if (response.status !== 201) return (setError(true));

    setPaymentCompleted(true);
  };

  const onError = error => {
    console.log(error);
    setProcessingPayment(false);
    setError(true);
  };

  return (
    <div>
      {processingPayment && <CircularProgress />}
      {error && <h5 className='header red-text'>Something went wrong! Reload the page and try again.</h5>}

      <PaymentButtons
        createOrder={ (data, actions) => createOrder(data, actions) }
        onApprove={ (data, actions) => onApprove(data, actions) }
        onError={ onError }
      />
    </div>
  );
};

export default PayPalButtons;
