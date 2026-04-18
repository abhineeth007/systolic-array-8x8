# 8×8 Systolic Array Tensor Processing Unit (TPU)

## Overview  
This repository contains the RTL design of a custom 8×8 systolic array TPU. It is designed to accelerate matrix multiplication used in deep learning.

## Architecture 

Im2Col
Converts a 1x2x3x5 tensor input into a 8x8 matrix. Using a kernal of size 2x2 with stride 1 and padding 0.

Processing Element (PE) Array  
An 8×8 grid of processing elements using a weight-stationary dataflow. Weights stay in each PE while input activations move through the array, reducing memory access.

Control Logic  
Controls data movement, timing, and accumulation of partial sums.

Memory and Data Flow  
Buffers are used to feed data into the array and keep computation continuous.

## Summary  
Implements a tensor to matrix converter using im2col. Further, a systolic array for matrix multiplication, focusing on data reuse and parallel computation.
