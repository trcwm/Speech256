// 
// Source part of speech synth
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//
// 

module SOURCE (
        clk, 
        rst_an, 
        period,         // period in 10kHz samples        
        amplitude,      // unsigned 15-bit desired amplitude of source output
        strobe,         // when strobe == '1' a new source_out will be generated
        period_done,    // is set to '1' at the end of the period
        source_out      // signed 16-bit source output
    );

	//////////// CLOCK //////////
	input clk;

    //////////// RESET, ACTIVE LOW //////////
    input rst_an;

	//////////// OUTPUTS //////////
	output reg signed [15:0] source_out;
    output reg period_done;

	//////////// INPUTS //////////
    input [14:0] amplitude;
    input [7:0]  period;
    input        strobe;

    // internal counter and data registers
    reg signed [7:0] periodcnt;
    reg        [16:0] lfsr;
    reg        last_strobe;

    always @(posedge clk, negedge rst_an)
    begin
        if (rst_an == 0)
        begin
            // reset values
            periodcnt <= 0;
            period_done <= 1;
            source_out <= 0;
            last_strobe <= 0;
            lfsr <= 17'h1;   //note: never reset the LFSR to zero!
        end
        else
        begin
            // default value
            period_done <= 0;

            if ((strobe == 1) && (last_strobe == 0))
            begin
                // if period == 0, we need to generate noise
                // else we generate a pulse wave
                if (period == 0)
                begin
                    // ------------------------------------------------------------
                    //   LFSR NOISE GENERATOR
                    // ------------------------------------------------------------
                    if (periodcnt == 64)                        
                    begin
                        periodcnt <= 0;
                        period_done <= 1;
                    end
                    else
                        periodcnt <= periodcnt + 1;
                    
                    // lfsr polynomial is X^17 + X^3 + 1
                    lfsr = {lfsr[15:0], lfsr[16] ^ lfsr[2]};
                    source_out <= lfsr[0] ? {1'b0, amplitude} : {1'b1, ~amplitude};
                end
                else
                begin
                    // ------------------------------------------------------------
                    //   PULSE GENERATOR
                    // ------------------------------------------------------------        
                    // make periodcnt count from 0 .. period-1
                    if (periodcnt == period)
                    begin
                        periodcnt <= 0;
                        period_done <= 1;
                    end
                    else
                        periodcnt <= periodcnt + 1;

                    if (periodcnt < 8)
                        source_out <= {1'b0, amplitude};
                    else
                        source_out <= 16'h0000;                            
                end
            end
            last_strobe <= strobe;
        end
    end

endmodule
