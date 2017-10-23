// 
// PWMDAC testbench
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

module CONTROLLER_TB;
    reg clk, rst_an; 
    
    reg [5:0] data_in;
    reg data_stb, serve_next;
    reg period_done;
    
    wire ldq;
    wire signed [7:0] coeff;
    wire coeff_load;
    wire [7:0]  period;
    wire [15:0] amp;
    wire [7:0]  dur;

    CONTROLLER u_controller (
        .clk        (clk),
        .rst_an     (rst_an),
        .ldq        (ldq),
        .data_in    (data_in),
        .data_stb   (data_stb),
        .period_out (period),
        .amp_out    (amp),
        .coeff_out  (coeff),
        .coeff_stb  (coeff_load),
        .period_done_in (period_done)
    );

    initial
    begin
        $dumpfile ("controller.vcd");
        $dumpvars;
        clk = 0;
        rst_an = 0;
        data_in = 6;
        data_stb = 0;
        period_done = 0;
        #5
        rst_an = 1;
        #5
        // load allophone
        data_stb = 1;
        #10
        data_stb = 0;
        serve_next = 1;
        #300000
        $finish;
    end

    always @(posedge clk)
    begin   
        ;
    end

    always
        #5 clk = !clk;

endmodule
