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

    real accu;

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
        accu = 0;
        #3
        rst_an = 1;
        #655360     
        $finish;
    end

    always @(posedge clk)
    begin
        if (din_ack)
        begin
            accu = accu + 1.0/256.0;
            if (accu > 1.0)
                accu = -1.0;
            din = $rtoi($sin(2.0*3.1415927*accu)*127.0);
        end
    end

    always
        #5 clk = !clk;

endmodule