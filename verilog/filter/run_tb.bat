mkdir bin
del bin\filter.vvp
C:\iverilog\bin\iverilog -o bin\filter.vvp -m va_math -g2005 -s FILTER_TB ..\spmul\spmul.v filter.v filter_tb.v
cd bin
C:\iverilog\bin\vvp filter.vvp -lxt2
cd ..
