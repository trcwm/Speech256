## Digilent DE0 board

* Altera EP3C16F484C6 FPGA

The DAC output is the UART_TX pin. It _really_ needs a 5kHz lowpass filter, otherwise you'll be deafened/greeted by a very loud 10kHz PWM carrier. Try two sections of a 1K ohm series resistor, followed by a 100nF capacitor to ground:

```


UART_TX pin ----RRRRR--------RRRRR---------o OUTPUT
                        |             |
                        C             C
                        C             C
                        C             C
                        |             |
                       GND           GND

```