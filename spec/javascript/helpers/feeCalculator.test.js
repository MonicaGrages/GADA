import { calculatePayPalFee, calculateTotalCost } from 'helpers/feeCalculator';
import { describe, expect, test } from '@jest/globals';

describe('calculatePayPalFee', () => {
  test('returns the expected fee amount', () => {
    expect(calculatePayPalFee(35)).toBeCloseTo(1.77);
    expect(calculatePayPalFee(10)).toBeCloseTo(0.87);
    expect(calculatePayPalFee(45)).toBeCloseTo(2.13);
  });
})

describe('calculateTotalCost', () => {
  test('returns total cost rounded to 2 decimal places', () => {
    expect(calculateTotalCost(35)).toBe('36.77');
    expect(calculateTotalCost(10)).toBe('10.87');
    expect(calculateTotalCost(45)).toBe('47.13');
  });
})
