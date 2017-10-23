mkdir bin
del bin\speech256_top.vvp
C:\iverilog\bin\iverilog -o bin\speech256_top.vvp -m va_math -g2005 -s SPEECH256_TOP_TB speech256_top.v speech256_top_tb.v ..\filter\filter.v ..\source\source.v ..\spmul\spmul.v ..\pwmdac\pwmdac.v ..\controller\controller.v ..\controller\ctrlrom.v ..\controller\xlat.v
cd bin
C:\iverilog\bin\vvp speech256_top.vvp -lxt2
cd ..
