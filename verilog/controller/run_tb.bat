python genctrlrom.py
mkdir bin
del bin\controller.vvp
del bin\xlat.vvp
C:\iverilog\bin\iverilog -o bin\xlat.vvp -m va_math -g2005 -s XLAT_TB xlat.v xlat_tb.v
C:\iverilog\bin\iverilog -o bin\controller.vvp -m va_math -g2005 -s CONTROLLER_TB controller.v controller_tb.v ctrlrom.v xlat.v
cd bin
@echo --== Running XLAT testbench ==--
C:\iverilog\bin\vvp xlat.vvp -lxt2
@echo --== Running CONTROLLER testbench ==--
C:\iverilog\bin\vvp controller.vvp -lxt2
cd ..
