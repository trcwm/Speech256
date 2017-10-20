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
        coef_in     = 0;
        coef_load   = 0;
        start       = 0;
        check_finish  = 0;

        #10
        rst_an = 1;

        // load all the coefficients
        #10
        coef_load = 1;
        // section 1
        coef_in     = {1'b0, 9'd64}; // sign-magnitude a1 = -0.25
        #10
        coef_in     = {1'b1, 9'd256}; // sign-magnitude a2 = 0.5
        #10
        // section 2
        coef_in     = {1'b0, 9'd0}; // sign-magnitude a1 = 0;
        #10
        coef_in     = {1'b0, 9'd0}; // sign-magnitude a1 = 0;
        #10
        // section 3
        coef_in     = {1'b0, 9'd0}; // sign-magnitude a1 = 0;
        #10
        coef_in     = {1'b0, 9'd0}; // sign-magnitude a1 = 0;
        #10
        // section 4
        coef_in     = {1'b0, 9'd0}; // sign-magnitude a1 = 0;
        #10
        coef_in     = {1'b0, 9'd0}; // sign-magnitude a1 = 0;
        #10
        // section 5
        coef_in     = {1'b0, 9'd0}; // sign-magnitude a1 = 0;
        #10
        coef_in     = {1'b0, 9'd0}; // sign-magnitude a1 = 0;
        #10
        // section 6
        coef_in     = {1'b0, 9'd0}; // sign-magnitude a1 = 0;
        #10
        coef_in     = {1'b0, 9'd0}; // sign-magnitude a1 = 0;
        #10
        coef_load = 0;
        start = 1;
        #50000;
        check_finish = 1;
    end

    always@(posedge clk)
    begin
        if ((done == 1) && (coef_load != 1))
            $display("%d", sig_out);
    end

    always
        #5 clk = !clk;

    always @(posedge done)
        if ((done == 1) && (check_finish == 1)) 
            $finish;

endmodule
