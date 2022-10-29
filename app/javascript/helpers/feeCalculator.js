const PAYPAL_FEE_RATE = 0.0349;
const FIXED_FEE = 0.49;

export function calculatePayPalFee(amount) {
  const calculatedRate = (1 + PAYPAL_FEE_RATE) * PAYPAL_FEE_RATE;
  const calculatedFixedFee = FIXED_FEE + FIXED_FEE * PAYPAL_FEE_RATE;

  return amount * calculatedRate + calculatedFixedFee;
}

export function calculateTotalCost(amount) {
  const rawAmount = amount + calculatePayPalFee(amount);

  return rawAmount.toFixed(2);
}

export function formattedPayPalFee(amount) {
  return calculatePayPalFee(amount).toFixed(2);
}
