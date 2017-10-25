// 
// Speech256 DE0 board top level
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

module Speech256_DE0 (
    CLOCK_50,
    SW,
    BUTTON,
    LEDG,
    UART_TXD
);

    input  CLOCK_50;
    input  [0:5] SW;
    input  [0:2] BUTTON;
    output [9:0] LEDG;
    output UART_TXD;

    reg  [5:0] data_in;
    reg  data_stb;
    reg  clk;
    reg  [3:0] divcnt; // clock divider counter
    reg  [2:0] cur_state, next_state;
    
    // debug signals for 16-bit DAC
    wire sample_stb;
    wire signed [15:0] sample_out;
    
    wire ldq;
    wire rst_an;

    SPEECH256_TOP u_speech256_top (
        .clk        (clk),
        .rst_an     (rst_an),
        .ldq        (ldq),
        .data_in    (SW),
        .data_stb   (data_stb),
        .pwm_out    (UART_TXD),
        .sample_out (sample_out),
        .sample_stb (sample_stb)
    );

    assign rst_an = 1'b1;

    parameter S_IDLE       = 4'b000,
              S_ALLOPHONE  = 4'b001,
              S_WAITDONE   = 4'b010;

    always @(posedge CLOCK_50)
    begin

        // clock divider to generate 2.5 MHz for Speech256
        if (divcnt > 9)
        begin
            clk <= !clk;
            divcnt <= 0;            
        end
        else
        begin
            divcnt <= divcnt + 1;
        end        
    end

    always @(posedge clk)
    begin
        cur_state <= next_state;
    end
    
    //assign LEDG[9:0] = sample_out[15:6];
    assign LEDG[0] = BUTTON[0];
    assign LEDG[1] = ldq;
    assign LEDG[2] = SW[2];
    assign LEDG[3] = SW[3];

    always @(*)
    begin
        // FSM defaults
        data_stb <= 0;
        next_state <= cur_state;
        
        case(cur_state)
        S_IDLE:
            begin
                if ((ldq == 1) && (BUTTON[0] == 1))
                    next_state <= S_ALLOPHONE;
                else
                    next_state <= S_IDLE;
            end
        S_ALLOPHONE:
            begin
                data_stb   <= 1;
                next_state <= S_WAITDONE;
            end
        S_WAITDONE:
            begin
                if (ldq == 0)
                    next_state <= S_IDLE;
            end
        default:
            begin
                next_state <= S_IDLE;
            end
        endcase
    end

endmodule
