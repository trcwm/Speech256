// 
// 16bit x 10bit signed serial/parallel multiplier.
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//
//
// 

module SPMUL (
        clk, 
        rst_an, 
        sig_in, 
        coef_in, 
        result_out,
        start,
        done
    );

	//////////// CLOCK //////////
	input clk;

    //////////// RESET, ACTIVE LOW //////////
    input rst_an;

    //////////// MULTIPLIER INPUTS //////////
    input signed [15:0] sig_in;
    input signed [9:0]  coef_in;
    input start;

	//////////// MULTIPLIER OUTPUT //////////
	output reg signed [15:0] result_out;
    output reg done;

    //////////// internal signals //////////
    reg signed [24:0] accumulator;
    reg signed [9:0]  coefreg;
    reg signed [15:0] sigreg;
    reg [3:0]         state;    // state machine state
    wire signed [15:0] bmul;
    
    reg domul,accu_clr;

    // accumulator 
    always @(posedge clk, negedge rst_an)
    begin
        if ((rst_an == 0) || (accu_clr == 1))
        begin
            accumulator <= 0;
        end
        else if (domul == 1)
            begin
                if (coefreg[9] == 1'b1)
                    accumulator <= {accumulator[23:0], 1'b0} + sigreg;
                else    
                    accumulator <= {accumulator[23:0], 1'b0};
                
                coefreg <= {coefreg[8:0], 1'b0};
            end
    end
           
    always @(posedge clk, negedge rst_an)
    begin
        if (rst_an == 0)
        begin
            // reset values
            result_out  <= 0;
            done        <= 0;
            coefreg     <= 0;
            sigreg      <= 0;
            state       <= 0;
            domul       <= 0;
            accu_clr    <= 1;
        end
        else
        begin
            // default values
            accu_clr <= 0;
            done     <= 0;
            domul    <= 0;
            state    <= state + 4'b0001;
            casex(state)
                4'b0000:
                    begin
                        coefreg  <= coef_in;
                        sigreg   <= sig_in;
                        accu_clr <= 1;

                        if (start == 1)
                        begin
                            state <= 4'b0001;
                        end
                        else    
                            state <= 4'b0000;
                    end
                4'b0001: 
                    begin
                        domul <= 1;
                    end
                4'b0010: 
                    begin
                        domul <= 1;
                    end
                4'b0011: 
                    begin
                        domul <= 1;
                    end
                4'b0100: 
                    begin
                        domul <= 1;
                    end
                4'b0101: 
                    begin
                        domul <= 1;
                    end
                4'b0110:
                    begin
                        domul <= 1;
                    end
                4'b0111:
                    begin
                        domul <= 1;
                    end
                4'b1000:
                    begin
                        domul <= 1;
                    end
                4'b1001:
                    begin
                        domul <= 1;
                    end
                4'b1010:
                    begin
                        domul <= 1;
                    end                    
                4'b1011:
                    begin
                        domul <= 0;
                        done <= 1;
                        result_out <= accumulator[23:8];
                        state <= 0;
                    end
                default:
                    state <= 0;
            endcase
        end
    end
endmodule
