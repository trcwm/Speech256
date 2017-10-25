// 
// SPMUL testbench
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

module SPMUL_TB;
    reg clk, rst_an, start; 
    reg signed [15:0] sig;
    reg signed [9:0]  coef;
    wire signed [15:0] result;
    wire done;

    SPMUL u_spmul (
        .clk     (clk),
        .rst_an  (rst_an),
        .sig_in  (sig),
        .coef_in (coef),
        .result_out  (result),
        .start   (start),
        .done    (done)
    );

    initial
    begin
        $dumpfile ("spmul.vcd");
        $dumpvars;
        clk    = 0;
        rst_an = 0;
        sig    = 16'h7FFF;
        coef   = 10'h3FF; // sign-magnitude
        start  = 1;
        #3
        rst_an = 1;
        #10
        start  = 0;
        #1024;
    end

    always
        #5 clk = !clk;

    always @(posedge done)
    begin
        if ((done == 1) && (start == 0))
        begin
            $display("Expected: %d, got %d", -32703 , result);
            $finish;
        end
    end
endmodule
