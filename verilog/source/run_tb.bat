mkdir bin
del bin\source.vvp
C:\iverilog\bin\iverilog -o bin\source.vvp -m va_math -g2005 -s SOURCE_TB source.v source_tb.v
cd bin
C:\iverilog\bin\vvp source.vvp -lxt2
cd ..
