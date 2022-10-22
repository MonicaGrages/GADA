import { addPayPalFee } from 'helpers/feeCalculator';
import { describe, expect, test } from '@jest/globals';

describe('addPayPalFee', () => {
  test('returns a float to 2 decimal places', () => {
    expect(addPayPalFee(35)).toBe('36.77');
    expect(addPayPalFee(10)).toBe('10.87');
  });
})
