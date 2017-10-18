// 
// FILTER testbench
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

module FILTER_TB;
    reg clk, rst_an, start, coef_load, check_finish; 
    reg signed [15:0] sig_in;
    reg signed [9:0]  coef_in;
    reg        [3:0]  reg_sel;
    wire signed [15:0] sig_out;
    wire done;

    FILTER u_filter (
        .clk        (clk),
        .rst_an     (rst_an),
        .coef_in    (coef_in),
        .coef_load  (coef_load),
        .sig_in     (sig_in),
        .sig_out    (sig_out),
        .start      (start),
        .done       (done)
    );

    integer i;

    initial
    begin
        $dumpfile ("filter.vcd");
        $dumpvars;
        clk    = 0;
        rst_an = 0;

        sig_in      = 16'h0100;
        coef_in     = 10'h000; // sign-magnitude
        coef_load   = 0;
        start       = 0;
        check_finish  = 0;

        #10
        rst_an = 1;
        #10
        coef_load = 1;
        coef_in     = 10'h21F; // sign-magnitude

        // load all the coefficients
        for(i=1; i<12; i=i+1)
        begin
            #10
            coef_load = 1;
            coef_in     = 10'h00F; // sign-magnitude
        end
        #10
        coef_load = 0;
        #10
        start = 1;
        #50000;
        check_finish = 1;
    end

    always
        #5 clk = !clk;

    always @(posedge done)
        if ((done == 1) && (check_finish == 1)) 
            $finish;

endmodule
