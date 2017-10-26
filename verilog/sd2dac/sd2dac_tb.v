// 
// PWMDAC testbench
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

module SD2DAC_TB;
    reg clk, rst_an; 
    reg signed [15:0] din;
    wire dacout, din_ack;

    real accu;

    SD2DAC u_sd2dac (
        .clk     (clk),
        .rst_an  (rst_an),
        .din     (din),
        .din_ack (din_ack),
        .dacout  (dacout)
    );

    integer fd;

    initial
    begin
        fd = $fopen("dacout.sw","wb");
        $dumpfile ("sd2dac.vcd");
        $dumpvars;
        clk = 0;
        rst_an = 0;
        din = 0;
        accu = 0;
        #3
        rst_an = 1;
        #1048576
        $fclose(fd);
        $finish;
    end

    always @(posedge clk)
    begin
        if (din_ack)
        begin
            accu = accu + 1.0/256.0;
            if (accu > 1.0)
                accu = -1.0;
            din = $rtoi($sin(2.0*3.1415927*accu)*10000.0);
        end
        if (dacout == 1)
            $fwrite(fd,"%u", 32'h7000_0000);
        else
            $fwrite(fd,"%u", 32'h9000_0000);
    end

    always
        #5 clk = !clk;

endmodule