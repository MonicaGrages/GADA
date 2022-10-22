const PAYPAL_FEE_RATE = 0.0349;
const FIXED_FEE = 0.49;

export function addPayPalFee(amount) {
  const effectiveRate = 1 + (1 + PAYPAL_FEE_RATE) * PAYPAL_FEE_RATE;
  const effectiveFixedFee = FIXED_FEE + FIXED_FEE * PAYPAL_FEE_RATE;

  const rawAmount = amount * effectiveRate + effectiveFixedFee;
  return rawAmount.toFixed(2);
}
