// 
// XLAT testbench
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

module XLAT_TB;    
    reg [7:0]  c8_in;
    wire [9:0] c10_out;

    XLAT u_xlat (
        c8_in, 
        c10_out
    );

    integer i;
    initial
    begin
        $dumpfile ("xlat.vcd");
        $dumpvars;
        c8_in[7] = 0;
        for(i=0; i<128; i=i+1)
        begin
            c8_in[6:0] = i;
            #10;
        end
        $finish;
    end

endmodule
