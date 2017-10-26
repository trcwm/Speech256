mkdir bin
del bin\sd2dac.vvp
C:\iverilog\bin\iverilog -o bin\sd2dac.vvp -m va_math -g2005 -s SD2DAC_TB sd2dac.v sd2dac_tb.v
cd bin
C:\iverilog\bin\vvp sd2dac.vvp
cd ..
