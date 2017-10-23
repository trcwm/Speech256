// 
// PWMDAC testbench
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

module SPEECH256_TOP_TB;
    reg clk, rst_an; 
    reg [5:0] data_in;
    reg data_stb;
    wire ldq,dac_out;

    SPEECH256_TOP u_speech256_top (
        .clk        (clk),
        .rst_an     (rst_an),
        .ldq        (ldq),
        .data_in    (data_in),
        .data_stb   (data_stb),
        .dac_out    (dac_out)
    );

    integer fd; // file descriptor

    initial
    begin
        fd = $fopen("dacout.sw","wb");
        $dumpfile ("speech256_top.vcd");
        $dumpvars;
        clk = 0;
        rst_an = 0;
        data_stb = 0;
        #5
        rst_an = 1;
        #5
        data_in = 6;
        data_stb = 1;
        #5
        data_stb = 0;
        #300000
        //$fclose(fd);
        $finish;
    end

    always @(posedge clk)
    begin   
        $fwrite(fd,"%u", {31'd0,dac_out});
    end

    always
        #5 clk = !clk;

endmodule
