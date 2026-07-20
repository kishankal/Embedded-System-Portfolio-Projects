# FIR Filter — Interview Answer & Design Flow

## How to Answer "Design a FIR Filter" in an Interview

> "First I define the specification — sample rate (Fs), passband cutoff (Fpass),
> stopband cutoff (Fstop), and required attenuation in dB.
> Then I calculate the number of taps using the Kaiser formula:
> N = (Atten_dB - 7.95) / (2.285 x transition_bandwidth).
> I select the window type based on attenuation requirement —
> Hamming for 40dB, Blackman for 74dB, Kaiser for anything above 75dB.
> I generate coefficients using scipy.signal.firwin in Python,
> then verify quantization error, symmetry, overflow, and DC gain.
> I calculate accumulator width from the bit width calculator to prevent overflow.
> Then I implement direct-form pipelined FIR in VHDL —
> delay line shift register for sample history,
> parallel multiply stage (all taps simultaneously),
> adder tree with saturation arithmetic for output.
> I verify with impulse response, DC gain test, and frequency sweep
> comparing 500Hz (passband) vs 3000Hz (stopband) attenuation."

---

## Complete Design Flow — Step by Step

### Step 1 — Specification (Sheet 1 Phase 1)
- Define Fs, Fpass, Fstop
- Calculate required attenuation: `Atten = 20 x log10(signal/noise_allowed)`
- Fill Sheet 1 before touching any tool

### Step 2 — Tap Count Calculation
Kaiser formula:
N = (Atten_dB - 7.95) / (2.285 x delta_omega) + 1
delta_omega = 2*pi * (Fstop - Fpass) / Fs
Round UP to next power of 2 (64, 128, 256)

### Step 3 — Window Selection (Sheet 3)
| Attenuation | Window | scipy |
|---|---|---|
| < 40 dB | Hanning | window='hann' |
| 40-50 dB | Hamming | window='hamming' |
| 60-75 dB | Blackman | window='blackman' |
| > 75 dB | Kaiser | window=('kaiser', beta) |
| Any | Kaiser | beta = 0.1102 x (Atten - 8.7) |

### Step 4 — Coefficient Generation (Python)
```python
from scipy import signal
h = signal.firwin(N_taps, Fpass/(Fs/2), window=('kaiser', beta))
```
Verify: quantization error, symmetry, overflow, DC gain = 1.0

### Step 5 — Bit Width Calculation (Sheet 4)
Max product = max_input x max_coef
Acc bits min = ceil(log2(N x max_product)) + 1
Recommended = min + 7 bits headroom
Output = bits[30:15] of accumulator (for Q1.15)

### Step 6 — VHDL ArchitectureStage 1: 
Delay line shift + Parallel multiply (all taps at once)
Stage 2: Adder tree + Saturation + Truncation
Latency: 2 clock cycles
Interface: AXI4-Stream (s_axis_tvalid/tready/tdata)

### Step 7 — Verification (Sheet 1 Phase 4)
- Test 1: Zero input -> zero output
- Test 2: Impulse -> coefficients visible in output
- Test 3: DC input -> DC output (gain = 1.0)
- Test 4: Low freq sine (passband) -> passes unchanged
- Test 5: High freq sine (stopband) -> attenuated

---

## Our Design — Audio Low-Pass Filter

| Parameter | Value | Source |
|---|---|---|
| Application | Telephone voice filter | Specification |
| Sample Rate | 8000 Hz | Specification |
| Passband | 1000 Hz | Specification |
| Stopband | 2000 Hz | Specification |
| Attenuation | 60 dB | Specification |
| Window | Kaiser beta=6 | Sheet 3 |
| Taps | 32 | Kaiser formula |
| Coef bits | 16 (Q1.15) | Sheet 4 |
| Data bits | 16 (Q1.15) | Sheet 4 |
| Accumulator | 42 bits | Sheet 4 |
| Quantization error | 1.52e-05 | Python output |
| Symmetric | True | Python output |
| DC Gain | 1.000 | Python output |
| SNR | 98.1 dB | Sheet 4 |

---

## Key Concepts — Never Forget

### Why Symmetric Coefficients Matter
Linear phase FIR — all frequencies delayed by same amount.
No phase distortion. Critical for audio, ECG, radar.

### Why Saturation (Not Wrap-Around)
Without saturation: +40000 wraps to -25536 (huge error).
With saturation: +40000 clamps to +32767 (small clipping).

### Why Parallel Multiply in FPGA
Software: 32 multiplications run sequentially (32 cycles).
FPGA: 32 multiplications run simultaneously (1 cycle).
This is the fundamental advantage of hardware over software.

### Why 42-bit Accumulator
32-bit product x 32 taps = needs 34 bits minimum.
Add 7 bits headroom = 41 bits -> use 42 bits.
Never guess accumulator width - always calculate from Sheet 4.

---

## Files in This Folder

| File | Description |
|---|---|
| fir_filter.vhd | Industry-standard 32-tap FIR, AXI4-Stream, pipelined |
| fir_filter_tb.vhd | 5-test verification testbench |
| coeff_find.py | Python coefficient generator (scipy) |
| FIR_Design_Reference_Table.xlsx | Industry checklist + window reference + bit calculator |

