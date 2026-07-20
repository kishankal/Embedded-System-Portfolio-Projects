# fir_coeff_generator.py
# Industry standard: use scipy to design filter coefficients
# Then quantize to fixed-point for VHDL

import numpy as np
from scipy import signal

# ── Filter specification ───────────────────────────────────
Fs        = 8000              # ← change from 1000
Fpass     = 1000              # ← change from 40
Fstop     = 2000              # ← change from 45
N_taps    = 32                # ← change from 64
COEF_BITS = 16      # coefficient word length
DATA_BITS = 16      # data word length

# ── Design FIR coefficients ────────────────────────────────
# firwin: windowed FIR design
# kaiser window: good stopband attenuation (~40dB)
h = signal.firwin(N_taps,
                  Fpass / (Fs/2),
                  window=('kaiser', 6.0))  # ← change from 'hamming'

print("Floating-point coefficients:")
for i, c in enumerate(h):
    print(f"  h[{i}] = {c:.8f}")

# ── Quantize to fixed-point Q1.15 ─────────────────────────
# Q1.15: 1 sign bit + 15 fractional bits
# Scale factor = 2^15 = 32768
SCALE = 2**(COEF_BITS - 1)  # = 32768

h_fixed = np.round(h * SCALE).astype(int)

print(f"\nFixed-point coefficients (Q1.15, scale={SCALE}):")
for i, c in enumerate(h_fixed):
    print(f"  h[{i}] = {c:6d}  (actual = {c/SCALE:.8f})")

# ── Verify quantization error ──────────────────────────────
h_reconstructed = h_fixed / SCALE
error = np.max(np.abs(h - h_reconstructed))
print(f"\nMax quantization error: {error:.2e}")

# ── Check symmetry ─────────────────────────────────────────
is_symmetric = np.allclose(h_fixed, h_fixed[::-1])
print(f"Symmetric coefficients: {is_symmetric}")

# ── Generate VHDL constant array ──────────────────────────
print("\n-- VHDL coefficient array (copy into your code):")
print("type t_coef_array is array(0 to N_TAPS-1) of")
print("     signed(COEF_WIDTH-1 downto 0);")
print("constant COEF : t_coef_array := (")
for i, c in enumerate(h_fixed):
    comma = "," if i < N_taps-1 else " "
    print(f"    {i} => to_signed({c:6d}, COEF_WIDTH){comma}  -- h[{i}]")
print(");")

# ── Check for overflow in fixed-point ─────────────────────
max_val = 2**(COEF_BITS-1) - 1
min_val = -(2**(COEF_BITS-1))
overflow = any(c > max_val or c < min_val for c in h_fixed)
print(f"\nOverflow in coefficients: {overflow}")