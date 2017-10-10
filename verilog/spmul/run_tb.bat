mkdir bin
del bin\spmul.vvp
C:\iverilog\bin\iverilog -o bin\spmul.vvp -m va_math -g2005 -s SPMUL_TB spmul.v spmul_tb.v
cd bin
C:\iverilog\bin\vvp spmul.vvp
cd ..
