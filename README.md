# DiP Architecture of Systolic Array for Matrix Multiplication Acceleration

## Overview
This repository contains the RTL design, verification, and hardware implementation of a scalable, energy-efficient systolic array based on the **DiP (Diagonal-Input and Permutated weight-stationary)** dataflow. 

While traditional AI hardware accelerators (like TPUs) utilize Weight Stationary (WS) systolic arrays, they heavily rely on synchronous First-In-First-Out (FIFO) buffers for input-output synchronization. These FIFOs consume significant chip area and power. Our implementation of the DiP architecture completely eliminates these synchronization FIFOs, leading to massive improvements in energy efficiency and up to a 50% increase in throughput by maximizing computational resource utilization.

This project is a hardware realization based on the 2025 IEEE research paper: *DiP: A Scalable, Energy-Efficient Systolic Array for Matrix Multiplication Acceleration*.

---

## Algorithm & Dataflow

1. Matrix Tiling Algorithm
To handle large matrices on a constrained hardware footprint, we implemented a matrix tiling algorithm. The matrices are divided into smaller blocks (tiles) that fit into our 4x4 on-chip systolic array.

// them anh 4.png

2. The DiP Dataflow
The core innovation of this project is the DiP dataflow, which features two main mechanisms:

 - Weight Matrix Permutation: While the original paper relies on weights being pre-rotated in software prior to loading, our design implements this permutation directly in hardware. We designed custom address generation logic that calculates specific read addresses on-the-fly, fetching the weights from memory in their correctly rotated and shifted order without requiring any software preprocessing.

 - Diagonal Input Movement: Inputs are fed into the first row and shifted diagonally in subsequent cycles.

// them anh trong bai bao

## Hardware Architecture & RTL Design

The system is designed using a Finite State Machine with Datapath (FSMD) model, separating the control logic from the computational logic.

1. Datapath Architecture

The datapath manages the flow of matrices from the Block RAM (BRAM) through the Processing Elements (PEs) and back. It consists of the following subsystems:

 - Address Generation Unit: Calculates dynamic memory addresses for continuous data streaming.

 - Processing Element (PE): A 2-stage pipelined Multiply-Accumulate (MAC) unit with independent control registers for inputs, weights, and accumulation results.

 - Accumulator (Partial Sum Addition): Retrieves temporarily stored data (partial sums) from memory and adds it to the newly computed MAC results to accumulate the final output matrix.

// them anh 11.png

2. Finite State Machine (FSM) Controller

The Control Unit is a robust 59-state FSM that orchestrates the entire matrix multiplication process, coordinating the i, j, and h loops of the tiled algorithm.

To hide memory latency and maximize PE utilization, the FSM implements a 3-layer pipeline:

 - Load Pipeline: Fetching and writing weights into the PEs.

 - Stream Pipeline: Streaming diagonal inputs into the array.

 - Compute & Write-back Pipeline: Processing the MAC operations and storing results back to BRAM.

## Performance & FPGA Implementation

The design was fully verified via Behavioral Simulation and deployed on hardware using **Xilinx ILA/VIO** (Integrated Logic Analyzer / Virtual Input/Output). Below are the post-implementation reports extracted from Xilinx Vivado.

### 1. Post-Implementation Timing Summary
The design successfully met all timing constraints at a target clock frequency of **100 MHz**.

| Setup (Max Delay) | Hold (Min Delay) |
| :--- | :--- |
| **WNS** (Worst Negative Slack): `+1.173 ns` | **WHS** (Worst Hold Slack): `+0.018 ns` |
| **TNS** (Total Negative Slack): `0.000 ns` | **THS** (Total Hold Slack): `0.000 ns` |
| **Timing Met:** ✅ Yes | **Timing Met:** ✅ Yes |

### 2. Resource Utilization (4x4 Systolic Array)
*Note: The available resources below are based on the target FPGA board. Please update the '[ ]' fields with your specific Vivado report numbers.*

| Site Type | Used | Available | Utilization (%) |
| :--- | :--- | :--- | :--- |
| **Slice LUTs** | 1,725 | [e.g., 20,800] | ~8.3% |
| **Slice Registers (FF)** | [Value] | [e.g., 41,600] | [Value]% |
| **Block RAM Tile (BRAM)** | 1 | [e.g., 50] | [Value]% |
| **DSPs** | [Value] | [e.g., 90] | [Value]% |

### 3. Throughput & Power Scalability
While the physical implementation was tested on a 4x4 array due to board constraints, theoretical projections for a scaled-up architecture demonstrate the massive efficiency of the DiP dataflow:

| Metric | 4x4 Array (Implementation) | 64x64 Array (Projection) |
| :--- | :--- | :--- |
| **Throughput** | [Your 4x4 TOPS] | 8,192 TOPS |
| **Energy Efficiency** | [Your 4x4 TOPS/W] | 9,548 TOPS/W |
