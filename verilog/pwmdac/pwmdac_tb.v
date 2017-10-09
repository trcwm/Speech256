// 
// PWMDAC testbench
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

module PWMDAC_TB;
    reg clk, rst_an; 
    reg signed [0:7] din;
    wire dacout, din_ack;

    PWMDAC u_pwmdac (
        .clk     (clk),
        .rst_an  (rst_an),
        .din     (din),
        .din_ack (din_ack),
        .dacout  (dacout)
    );

    initial
    begin
        $dumpfile ("pwmdac.vcd");
        $dumpvars;
        clk = 0;
        rst_an = 0;
        din = 0;
        #3
        rst_an = 1;
        #10240      
        $finish;
    end

    always
        #5 clk = !clk;

endmodule