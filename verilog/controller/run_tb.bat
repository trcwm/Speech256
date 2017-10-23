python genctrlrom.py
mkdir bin
del bin\controller.vvp
C:\iverilog\bin\iverilog -o bin\controller.vvp -m va_math -g2005 -s CONTROLLER_TB controller.v controller_tb.v ctrlrom.v
cd bin
C:\iverilog\bin\vvp controller.vvp -lxt2
cd ..
