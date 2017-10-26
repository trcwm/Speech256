// 
// Speecht256 top level
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//
// 

module SPEECH256_TOP (
        clk,        // global Speech256 clock (256*10kHz)
        rst_an,     
        ldq,        // load request, is high when new allophone can be loaded
        data_in,    // allophone input
        data_stb,   // allophone strobe input
        pwm_out,    // 1-bit PWM DAC output
        sample_out,
        sample_stb
    );

	//////////// CLOCK //////////
	input clk;

    //////////// RESET, ACTIVE LOW //////////
    input rst_an;

	//////////// OUTPUTS //////////
	output pwm_out;
    output ldq;
    output signed [15:0] sample_out;
    output sample_stb;

	//////////// INPUTS //////////
    input [5:0] data_in;
    input       data_stb;


    // internal counter and data registers
    wire pwmdac_ack, src_strobe;    
    wire signed [15:0] sig_source;
    wire signed [15:0] sig_filter;
    wire period_done;
    wire clear_states;

    wire [7:0]  period;
    wire [7:0]  dur;
    wire [15:0] amp;
    
    wire signed  [9:0]  coef_bus;
    wire                coef_load;
    
    wire done;

    SOURCE u_source (
        .clk        (clk),
        .rst_an     (rst_an),
        .period     (period),
        .amplitude  (amp[14:0]),
        .strobe     (src_strobe),
        .period_done (period_done),
        .source_out  (sig_source)
    );

    FILTER u_filter (
        .clk        (clk),
        .rst_an     (rst_an),
        .coef_in    (coef_bus),
        .coef_load  (coef_load),
        .clear_states (clear_states),
        .sig_in     (sig_source),
        .sig_out    (sig_filter),
        .start      (pwmdac_ack),
        .done       (src_strobe)
    );

    `ifdef USE_SDDAC
    SD2DAC u_sd2dac (
        .clk        (clk),
        .rst_an     (rst_an),
        .din        ($signed({sig_filter[11:0],4'h0})), // add +24dB gain .. FIXME: add saturation ??
        .din_ack    (pwmdac_ack),
        .dacout     (pwm_out)
    );
    `else
    PWMDAC u_pwmdac (
        .clk        (clk),
        .rst_an     (rst_an),
        .din        (sig_filter[11:4]), // add +24dB gain .. FIXME: add saturation ??
        .din_ack    (pwmdac_ack),
        .dacout     (pwm_out)
    );    
    `endif

    CONTROLLER u_controller (
        .clk        (clk),
        .rst_an     (rst_an),
        .ldq        (ldq),
        .data_in    (data_in),
        .data_stb   (data_stb),
        .period_out (period),
        .amp_out    (amp),
        .coeff_out  (coef_bus),
        .coeff_stb  (coef_load),
        .clear_states (clear_states),
        .period_done_in (period_done)
    );

    assign sample_out = sig_filter[15:0];
    assign sample_stb = src_strobe;

    always @(posedge clk, negedge rst_an)
    begin
        if (rst_an == 0)
        begin
            // reset values
        end
        else
        begin
            // clocked process
        end
    end

endmodule
