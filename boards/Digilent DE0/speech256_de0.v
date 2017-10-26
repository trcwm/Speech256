// 
// Speech256 DE0 board top level
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

`define USE_SDDAC

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
    
    reg [2:0] rom_addr;
    reg [5:0] rom_data;
    reg inc_rom_addr;

    // debug signals for 16-bit DAC
    wire sample_stb;
    wire signed [15:0] sample_out;
    
    wire ldq;
    wire rst_an;

    SPEECH256_TOP u_speech256_top (
        .clk        (clk),
        .rst_an     (rst_an),
        .ldq        (ldq),
        .data_in    (rom_data),
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
        if (inc_rom_addr == 1)
            rom_addr <= rom_addr + 1;
    end
    
    //assign LEDG[9:0] = sample_out[15:6];
    assign LEDG[0] = BUTTON[0];
    assign LEDG[1] = ldq;
    assign LEDG[2] = SW[2];
    assign LEDG[3] = SW[3];
    assign LEDG[4] = 0;

    always @(*)
    begin
        // FSM defaults
        data_stb <= 0;
        inc_rom_addr <= 0;
        next_state <= cur_state;
        
        case(cur_state)
        S_IDLE:
            begin
                if ((ldq == 1) && (BUTTON[0] == 1))
                begin
                    inc_rom_addr <= 1;
                    next_state <= S_ALLOPHONE;
                end
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
                begin
                    inc_rom_addr <= 1;
                    next_state <= S_IDLE;
                end
            end
        default:
            begin
                next_state <= S_IDLE;
            end
        endcase

        // allophone ROM
        // hello, world
        case (rom_addr)
            3'd0:   
                rom_data <= 6'h1B;
            3'd1:   
                rom_data <= 6'h07;
            3'd2:   
                rom_data <= 6'h2D;
            3'd3:   
                rom_data <= 6'h35;
            3'd4:   
                rom_data <= 6'h03;
            3'd5:   
                rom_data <= 6'h2E;
            3'd6:   
                rom_data <= 6'h1E;
            3'd7:   
                rom_data <= 6'h33;
            3'd8:   
                rom_data <= 6'h2D;
            3'd9:   
                rom_data <= 6'h15;
            3'd10:   
                rom_data <= 6'h03;
            default:   
                rom_data <= 6'h00;
        endcase
    end

endmodule
