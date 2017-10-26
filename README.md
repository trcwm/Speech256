![Speech256](assets/logo_small.png)

An FPGA implementation of a classic 80ies speech synthesizer in Verilog.

## Introduction

* Platform agnostic implementation.

## FPGA requirements
* 4 K ROM

Quartus II 13.1 synthesis results (Digilent DE0 board):
```
Flow Status	Successful - Thu Oct 26 16:47:44 2017
Quartus II 64-Bit Version	13.1.0 Build 162 10/23/2013 SJ Web Edition
Revision Name	Speech256_DE0
Top-level Entity Name	Speech256_DE0
Family	Cyclone III
Device	EP3C16F484C6
Timing Models	Final
Total logic elements	657 / 15,408 ( 4 % )
Total combinational functions	571 / 15,408 ( 4 % )
Dedicated logic registers	484 / 15,408 ( 3 % )
Total registers	484
Total pins	21 / 347 ( 6 % )
Total virtual pins	0
Total memory bits	32,868 / 516,096 ( 6 % )
Embedded Multiplier 9-bit elements	0 / 112 ( 0 % )
Total PLLs	0 / 4 ( 0 % )
```

## Description of blocks

### SPMUL
A serial/parallel multiplier with one 10-bit sign-magnitude and one 2's complement 16-bit input. The 10-bit input range represents -1 .. 1.

### SOURCE
The source consists of a LFSR noise generator and a pulse generator with a settable period/duration.

### FILTER
A 12-pole filter engine that takes 12 10-bit sign-magnitude filter coefficients and a 16-bit input. The 12-pole filter is built from second-order sections, each having coefficients A1 and A2. Each filter coefficient has a range of -1 .. 1.

The second-order filter transfer function is H(z) = 1 / (1 - 2 * A1 * z^-1 - A2 * z^-2).

### CONTROLLER
The controller reads the allophones from the control bus and generates the necessary signals to drive the source and filter blocks. The parameters for the source and filter are encoded in a 4K ROM by means of high-level instructions.

## License
TBD.

This project was done during the [Retro Challenge 2017/10 contest](http://www.retrochallenge.org).
<br>
![Retrochallenge](assets/retrochallenge_logo.png)