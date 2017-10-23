// 
// 12th order all-pole filter with
// internal coefficient RAM
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

//
// MEH!, the FSM needs a rewrite
// 
// * split into clocked and unclocked ALWAYS
//   and proper state names.
//

module FILTER (
        clk, 
        rst_an, 
        
        // coefficient loading interface
        coef_in,        // 10 bit sign-magnitude coefficient
        coef_load,      // pulse '1' to load the coefficient into the internal register

        // signal I/O and handshaking
        sig_in,         // 16-bit (scaled) source input signal
        sig_out,        // 16-bit filter output signal
        start,          // trigger processing of the input signal
        done            // goes to '1' when sig_out has valid data
    );
    parameter DEBUG = 0; //defult value

	//////////// CLOCK //////////
	input clk;

    //////////// RESET, ACTIVE LOW //////////
    input rst_an;

    //////////// FILTER INPUTS //////////
    input signed [15:0] sig_in;
    input signed [9:0]  coef_in;
    input start, coef_load;

	//////////// FILTER OUTPUTS //////////
	output wire signed [15:0] sig_out;
    output reg done;

    //////////// internal signals //////////
    reg signed [9:0]  coefmem [0:11];   // coefficient memory / shift register
    reg signed [15:0] state1  [0:5];    // state 1 memory / shift register
    reg signed [15:0] state2  [0:5];    // state 2 memory / shift register
    reg signed [15:0] accu;             // accumulator

    reg mul_start;
    reg state_sel;
    reg accu_sel;
    reg do_accu;
    reg double_mode;
    reg update_states;
    reg update_coeffs;
    reg [3:0] cur_state;
    reg unsigned [2:0] section;

    wire mul_done;
    wire signed [15:0] mul_result, accu_in, mul_in;
    wire [9:0] mul_coeff;

    integer i;

    // serial/parallel mulitplier
    SPMUL u_spmul (
        .clk        (clk),
        .rst_an     (rst_an),
        .sig_in     (mul_in),
        .coef_in    (mul_coeff),
        .result_out (mul_result),
        .start      (mul_start),
        .done       (mul_done)
    );

    // signal input mux for multipliers
    assign mul_in = (state_sel) ? state2[5] : state1[5];
    assign accu_in = (accu_sel) ? accu : sig_in;
    assign mul_coeff = coefmem[11];
    assign sig_out = accu;

    // clocked stuff..
    always @(posedge clk, negedge rst_an)
    begin
        if (rst_an == 0)
        begin
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // reset cycle here ..
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            for(i=0; i<6; i=i+1)
            begin
                state1[i]  <= 0;
                state2[i]  <= 0;
            end
            for(i=0; i<12; i=i+1)
            begin
                coefmem[i] <= 0;
            end

            // accumulator
            accu      <= 0;
            accu_sel  <= 0;
            state_sel <= 0;
            do_accu   <= 0;
            double_mode <= 0;

            update_states <= 0;
            update_coeffs <= 0;
            mul_start     <= 0;
            cur_state     <= 4'b0000;
            done          <= 0;
            section       <= 0;
        end
        else
        begin
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // regular clock cycle here ..
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            // update the filter states if necessary
            if (update_states == 1)
            begin
                state1[0] <= accu;
                state2[0] <= state1[5];   

                for(i=1; i<6; i=i+1)
                begin
                    state1[i] <= state1[i-1];
                    state2[i] <= state2[i-1];
                end
                //$display("BOOM %d %d %d %d %d %d %d", accu, state1[0], state1[1], state1[2],state1[3],state1[4],state1[5]);
            end

            // update the coefficients if necessary
            if ((update_coeffs) || (coef_load))
            begin
                for(i=1; i<12; i=i+1)
                begin
                    coefmem[i] <= coefmem[i-1];
                end
                // load from external interface if coef_load = 1
                // else just rotate
                if (coef_load == 1)
                begin
                    coefmem[0] <= coef_in;
                    //$display("Loaded coefficient: coefmem[0] = %xh", coef_in);
                end
                else
                    coefmem[0] <= coefmem[11];
            end

            // update the accumulator if necessary
            if (do_accu)
            begin
                if (double_mode)
                    accu <= accu_in + {mul_result[14:0], 1'b0};                    
                else
                    accu <= accu_in + mul_result;
            end

            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            // control state machine here .. 
            // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            // defaults
            done      <= 0;
            do_accu   <= 0;
            mul_start <= 0;
            state_sel <= 0;
            accu_sel  <= 0;
            double_mode <= 0;
            update_states <= 0;
            update_coeffs <= 0;            
            case(cur_state)
                4'b0000: // IDLE state
                    begin
                        done <= 1;
                        section <= 0;                        
                        if (start == 1)
                        begin
                            // state1 * coeff[0]
                            state_sel <= 0; // state 1 as mul input
                            mul_start <= 1; // trigger multiplier
                            cur_state <= 4'b0001;

                            if (DEBUG == 1)
                            begin
                                for(i=0; i<6; i=i+1)
                                begin
                                    $display("Section %d:   %d   %d", i, state1[i], state2[i]);
                                end
                            end
                            
                        end
                    end
                4'b0001: // Dummy cycle to wait for mul_done
                         // to reach a valid state
                    begin
                        cur_state <= 4'b0010;
                    end
                4'b0010: // wait for multiplier to complete
                    begin
                        if (mul_done == 1)
                        begin
                            cur_state <= 4'b0011;
                            accu_sel <= 0; // accu = sig_in + mul_result
                            do_accu  <= 1;
                            double_mode <= 1; // a1 coefficient has double the weight
                        end
                    end
                4'b0011: // update accu, 1st section only!
                    begin                        
                        cur_state <= 4'b0100;
                        update_coeffs <= 1; // advance to coeff[1]
                    end
                4'b0100: // state2 * coeff[1]
                    begin
                        state_sel <= 1; // state 2 as mul input
                        mul_start <= 1; // trigger multiplier
                        cur_state <= 4'b0101;
                    end
                4'b0101: // dummy state to wait for mul_done
                         // to become valid
                    begin
                        cur_state <= 4'b0110;
                    end                         
                4'b0110: // wait for multiplier to complete
                    begin
                        if (mul_done == 1)
                        begin
                            section   <= section + 4'b001;  // increment section number               
                            cur_state <= 4'b0111;
                            accu_sel <= 1; // accu = accu + mul_result
                            do_accu  <= 1;                            
                        end
                    end                    
                4'b0111: // update accumulator and filter states
                    begin
                        update_coeffs <= 1; // advance to next section..
                        update_states <= 1;

                        // check if this is the last section..
                        if (section==4'b0110)
                        begin
                            cur_state <= 4'b0000;   // one complete filter set done..
                        end
                        else
                            cur_state <= 4'b1000;   // next..
                    end
                4'b1000: 
                    begin
                        // next section: state1 * coeff[0]
                        cur_state <= 4'b1001;
                        state_sel <= 0; // state 1 as mul input
                        mul_start <= 1; // trigger multiplier                            
                    end
                4'b1001: // Dummy cycle to wait for mul_done
                         // to reach a valid state
                    begin
                        cur_state <= 4'b1010;
                    end
                4'b1010: // wait for multiplier to complete
                    begin
                        if (mul_done == 1)
                        begin
                            cur_state <= 4'b1011;
                            accu_sel <= 1; // accu = accu + mul_result
                            do_accu  <= 1;
                            double_mode <= 1; // a1 coefficient has double the weight
                        end
                    end
                4'b1011: // update accu, 2nd..5th section only!
                    begin
                        update_coeffs <= 1; // advance to coeff[1]
                        cur_state <= 4'b0100;
                    end
                default:
                    cur_state <= 4'b0000;
            endcase
        end
    end

endmodule    
