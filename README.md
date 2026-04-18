```markdown
# Systolic Array Based 2D Convolution Accelerator

## Overview
This project implements a Verilog-based systolic array accelerator for 2D convolution on a small multi-channel input tensor. The design demonstrates the complete hardware flow for convolution, starting from `im2col` address generation and ending with aligned convolution outputs from a systolic array.

The implementation is intended for:
- RTL simulation
- Cadence Genus synthesis
- Innovus backend flow

---

## Problem Configuration

### Input Tensor
- Shape: `1 x 2 x 3 x 5`
- Batch size: `1`
- Channels: `2`
- Height: `3`
- Width: `5`

### Kernel
- Kernel size: `2 x 2`
- Input channels per kernel: `2`
- Weights per kernel: `2 x 2 x 2 = 8`

### Output Feature Map
- Output height: `3 - 2 + 1 = 2`
- Output width: `5 - 2 + 1 = 4`
- Total output positions: `2 x 4 = 8`

Since each sliding window contains `8` values and there are `8` windows, the `im2col` matrix size is:

```text
8 x 8
```

---

## Architecture

The hardware dataflow is:

```text
Input Tensor
   -> im2col Address Generator
   -> Serial-to-Parallel + Skew
   -> 8x8 Systolic Array
   -> Deskew
   -> Final Outputs
```

### Block Description
- `im2col_addr_gen`
  - Generates memory addresses for each convolution window in `im2col` order.

- `S2P_Skew_OneShot`
  - Captures 8 serial values and launches them into the array with row-wise delay.

- `Processing_Element`
  - Performs signed multiply-accumulate (MAC) operations.

- `Systolic_Array_8x8`
  - Connects 64 processing elements in an 8x8 systolic structure.

- `Deskew_8x8`
  - Aligns staggered outputs from all array columns.

- `Conv2Ch2x2_SystolicArray_Top`
  - Integrates the complete accelerator.

---

## Active Kernels

The top module currently uses:

```verilog
ACTIVE_KERNELS = 2
```

This means:
- Columns `0` and `1` are active
- Columns `2` to `7` are zero-padded

This choice keeps the design scalable while making manual verification and report presentation easier.

---

## Kernel Values

The kernel flattening order is:

```text
idx0 = ch0[0][0]
idx1 = ch0[0][1]
idx2 = ch0[1][0]
idx3 = ch0[1][1]
idx4 = ch1[0][0]
idx5 = ch1[0][1]
idx6 = ch1[1][0]
idx7 = ch1[1][1]
```

### Kernel 0
Flattened:
```text
[1, 0, 0, -1, 1, 1, 0, 0]
```

Structured form:

Channel 0:
```text
[ 1  0 ]
[ 0 -1 ]
```

Channel 1:
```text
[ 1  1 ]
[ 0  0 ]
```

### Kernel 1
Flattened:
```text
[0, 1, 1, 0, -1, 0, 0, 1]
```

Structured form:

Channel 0:
```text
[ 0  1 ]
[ 1  0 ]
```

Channel 1:
```text
[-1  0 ]
[ 0  1 ]
```

---

## Expected Outputs

For the current hardcoded tensor and the two active kernels, the expected aligned outputs are:

### Kernel 0
```text
-9, -11, -13, -15, -19, -21, -23, -25
```

### Kernel 1
```text
2, 4, 6, 8, 12, 14, 16, 18
```

### Unused Kernel Columns
```text
0
```

---

## File Structure

### RTL
- `Processing_Element.v`
- `im2col_addr_gen.v`
- `S2P_Skew_OneShot.v`
- `Systolic_Array_8x8.v`
- `Deskew_8x8.v`
- `Conv2Ch2x2_SystolicArray_Top.v`

### Testbenches
- `tb_processing_element.v`
- `tb_im2col_addr_gen.v`
- `tb_s2p_skew_oneshot.v`
- `tb_conv2ch2x2_systolic_array.v`

### Synthesis Files
- `systolic_constraints.sdc`
- `run_genus.tcl`

---

## Verification Strategy

The design was verified hierarchically.

### 1. `im2col_addr_gen`
Verified:
- correct address sequencing
- total of `64` address reads
- correct final address coverage

### 2. `S2P_Skew_OneShot`
Verified:
- 8-sample capture
- one-shot launch behavior
- staircase-style skew across outputs

### 3. `Processing_Element`
Verified:
- weight load phase
- signed multiplication
- signed accumulation
- correct `psum_out`

### 4. Full Top Module
Verified:
- complete convolution pipeline
- correct aligned outputs
- correct multi-kernel behavior
- zero output for inactive columns

---

## Running Simulation

### Module-Level Simulation
Use the corresponding RTL file(s) with each testbench:

- `im2col_addr_gen.v` + `tb_im2col_addr_gen.v`
- `S2P_Skew_OneShot.v` + `tb_s2p_skew_oneshot.v`
- `Processing_Element.v` + `tb_processing_element.v`

### Full-System Simulation
Compile the following files together:

- `Processing_Element.v`
- `im2col_addr_gen.v`
- `S2P_Skew_OneShot.v`
- `Systolic_Array_8x8.v`
- `Deskew_8x8.v`
- `Conv2Ch2x2_SystolicArray_Top.v`
- `tb_conv2ch2x2_systolic_array.v`

---

## Running Synthesis

Synthesis is performed using Cadence Genus.

Required files:
- RTL files
- `systolic_constraints.sdc`
- `run_genus.tcl`
- standard-cell liberty file (`.lib`)

### Basic Flow
1. Set the correct library path in `run_genus.tcl`
2. Read RTL files
3. Elaborate the top module
4. Run design checks
5. Read timing constraints
6. Synthesize and optimize
7. Generate reports and mapped netlist

After synthesis, the mapped netlist can be used in Innovus for place-and-route.

---

## Key Contributions
This project demonstrates:
- hardware mapping of 2D convolution using a systolic array
- `im2col`-based window extraction
- skewed data injection for systolic processing
- signed MAC-based computation
- hierarchical RTL verification
- synthesis-ready hardware design flow

---

## Future Improvements
Possible extensions include:
- enabling all 8 kernel columns
- supporting larger tensors and kernels
- adding programmable weight storage
- integrating memory interfaces
- performing post-synthesis and post-layout verification

---

## Summary
This project presents a compact but complete hardware implementation of multi-channel convolution using a systolic array. It demonstrates how convolution can be transformed into structured dataflow through `im2col`, mapped onto a regular MAC array, and verified from module level up to full-system integration.
```
