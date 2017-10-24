![Speech256](assets/logo_small.png)

An FPGA implementation of a classic 80ies speech synthesizer in Verilog.

## Introduction

* Platform agnostic implementation.

## FPGA requirements
* 4 K ROM

## Description of blocks

### SPMUL
A serial/parallel multiplier with one 10-bit sign-magnitude and one 2's complement 16-bit input. The 10-bit input range represents -1 .. 1.

### SOURCE
The source consists of a LFSR noise generator and a pulse generator with a settable period/duration.

### FILTER
A 12-pole filter engine that takes 12 10-bit sign-magnitude filter coefficients and a 16-bit input. The 12-pole filter is built from second order sections, each having coefficients A1 and A2. Each filter coefficient is has a range of -1 .. 1.

The second order filter transfer function is H(z) = 1 / (1 - 2*A1*z^-1 - 2*A2*z^-2).

### CONTROLLER
The controller reads the allophones from the control bus and generates the necessary signals to drive the source and filter blocks. The parameters for the source and filter are encoded in a 4K ROM by means of high-level instructions.

## License
TBD.

This project was done during the [Retro Challenge 2017/10 contest](http://www.retrochallenge.org).
<br>
![Retrochallenge](assets/retrochallenge_logo.png)