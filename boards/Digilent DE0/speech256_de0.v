// 
// Speech256 DE0 board top level
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

//`define USE_SDDAC

module Speech256_DE0 (
    CLOCK_50,
    SW,
    BUTTON,
    LEDG,
    UART_TXD,
    HEX1_D,
    HEX2_D
);

    input  CLOCK_50;
    input  [0:5] SW;
    input  [0:2] BUTTON;
    output [6:0] HEX1_D;
    output [6:0] HEX2_D;
    output [9:0] LEDG;
    output UART_TXD;

    reg  [5:0] data_in;
    reg  data_stb;
    reg  clk;
    reg  [3:0] divcnt; // clock divider counter
    reg  [2:0] cur_state, next_state;
    
    reg [7:0] rom_addr;
    reg [5:0] rom_data;
    reg inc_rom_addr;

    // debug signals for 16-bit DAC
    wire sample_stb;
    wire signed [15:0] sample_out;
    
    wire ldq;
    wire rst_an;

    // 7-segment display for allophone display
    segmentdisplay u_disp1 (
        .clk            (clk),
        .latch          (data_stb),
        .hexdigit_in    (rom_data[3:0]),
        .display_out    (HEX1_D)
    );

    segmentdisplay u_disp2 (
        .clk            (clk),
        .latch          (data_stb),
        .hexdigit_in    ({2'b00, rom_data[5:4]}),
        .display_out    (HEX2_D)
    );

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
                //if ((ldq == 1) && (BUTTON[0] == 1))
                if (ldq == 1)
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
`ifdef HELLO_WORLD        
        case (rom_addr)
            4'd0:   
                rom_data <= 6'h1B;
            4'd1:   
                rom_data <= 6'h07;
            4'd2:   
                rom_data <= 6'h2D;
            4'd3:   
                rom_data <= 6'h35;
            4'd4:   
                rom_data <= 6'h03;
            4'd5:   
                rom_data <= 6'h2E;
            4'd6:   
                rom_data <= 6'h1E;
            4'd7:   
                rom_data <= 6'h33;
            4'd8:   
                rom_data <= 6'h2D;
            4'd9:   
                rom_data <= 6'h15;
            4'd10:   
                rom_data <= 6'h03;
            default:   
                rom_data <= 6'h03;
        endcase
    end
`else
        case (rom_addr)
            8'h00: rom_data <= 6'h21;
            8'h01: rom_data <= 6'h14;
            8'h02: rom_data <= 6'h00;
            8'h03: rom_data <= 6'h2B;
            8'h04: rom_data <= 6'h13;
            8'h05: rom_data <= 6'h04;
            8'h06: rom_data <= 6'h21;
            8'h07: rom_data <= 6'h14;
            8'h08: rom_data <= 6'h00;
            8'h09: rom_data <= 6'h2B;
            8'h0A: rom_data <= 6'h13;
            8'h0B: rom_data <= 6'h03;
            8'h0C: rom_data <= 6'h0D;
            8'h0D: rom_data <= 6'h3E;
            8'h0E: rom_data <= 6'h2D;
            8'h0F: rom_data <= 6'h02;
            8'h10: rom_data <= 6'h10;
            8'h11: rom_data <= 6'h13;
            8'h12: rom_data <= 6'h02;
            8'h13: rom_data <= 6'h0D;
            8'h14: rom_data <= 6'h27;
            8'h15: rom_data <= 6'h16;
            8'h16: rom_data <= 6'h04;
            8'h17: rom_data <= 6'h06;
            8'h18: rom_data <= 6'h10;
            8'h19: rom_data <= 6'h02;
            8'h1A: rom_data <= 6'h18;
            8'h1B: rom_data <= 6'h28;
            8'h1C: rom_data <= 6'h27;
            8'h1D: rom_data <= 6'h14;
            8'h1E: rom_data <= 6'h15;
            8'h1F: rom_data <= 6'h03;
            8'h20: rom_data <= 6'h06;
            8'h21: rom_data <= 6'h02;
            8'h22: rom_data <= 6'h2A;
            8'h23: rom_data <= 6'h1A;
            8'h24: rom_data <= 6'h0B;
            8'h25: rom_data <= 6'h11;
            8'h26: rom_data <= 6'h03;
            8'h27: rom_data <= 6'h21;
            8'h28: rom_data <= 6'h1F;
            8'h29: rom_data <= 6'h02;
            8'h2A: rom_data <= 6'h1D;
            8'h2B: rom_data <= 6'h1A;
            8'h2C: rom_data <= 6'h0D;
            8'h2D: rom_data <= 6'h04;
            8'h2E: rom_data <= 6'h21;
            8'h2F: rom_data <= 6'h14;
            8'h30: rom_data <= 6'h23;
            8'h31: rom_data <= 6'h04;
            8'h32: rom_data <= 6'h19;
            8'h33: rom_data <= 6'h07;
            8'h34: rom_data <= 6'h07;
            8'h35: rom_data <= 6'h37;
            8'h36: rom_data <= 6'h37;
            8'h37: rom_data <= 6'h02;
            8'h38: rom_data <= 6'h1A;
            8'h39: rom_data <= 6'h0B;
            8'h3A: rom_data <= 6'h15;
            8'h3B: rom_data <= 6'h03;
            8'h3C: rom_data <= 6'h38;
            8'h3D: rom_data <= 6'h0F;
            8'h3E: rom_data <= 6'h35;
            8'h3F: rom_data <= 6'h04;
            8'h40: rom_data <= 6'h2B;
            8'h41: rom_data <= 6'h3C;
            8'h42: rom_data <= 6'h35;
            8'h43: rom_data <= 6'h03;
            8'h44: rom_data <= 6'h2E;
            8'h45: rom_data <= 6'h0F;
            8'h46: rom_data <= 6'h0F;
            8'h47: rom_data <= 6'h0B;
            8'h48: rom_data <= 6'h03;
            8'h49: rom_data <= 6'h0D;
            8'h4A: rom_data <= 6'h1F;
            8'h4B: rom_data <= 6'h03;
            8'h4C: rom_data <= 6'h1D;
            8'h4D: rom_data <= 6'h0E;
            8'h4E: rom_data <= 6'h13;
            8'h4F: rom_data <= 6'h03;
            8'h50: rom_data <= 6'h28;
            8'h51: rom_data <= 6'h28;
            8'h52: rom_data <= 6'h3A;
            8'h53: rom_data <= 6'h03;
            8'h54: rom_data <= 6'h28;
            8'h55: rom_data <= 6'h28;
            8'h56: rom_data <= 6'h06;
            8'h57: rom_data <= 6'h23;
            8'h58: rom_data <= 6'h03;
            8'h59: rom_data <= 6'h37;
            8'h5A: rom_data <= 6'h37;
            8'h5B: rom_data <= 6'h0C;
            8'h5C: rom_data <= 6'h1E;
            8'h5D: rom_data <= 6'h02;
            8'h5E: rom_data <= 6'h29;
            8'h5F: rom_data <= 6'h37;
            8'h60: rom_data <= 6'h03;
            8'h61: rom_data <= 6'h37;
            8'h62: rom_data <= 6'h37;
            8'h63: rom_data <= 6'h07;
            8'h64: rom_data <= 6'h07;
            8'h65: rom_data <= 6'h23;
            8'h66: rom_data <= 6'h0C;
            8'h67: rom_data <= 6'h0B;
            8'h68: rom_data <= 6'h03;
            8'h69: rom_data <= 6'h14;
            8'h6A: rom_data <= 6'h02;
            8'h6B: rom_data <= 6'h0D;
            8'h6C: rom_data <= 6'h03;
            8'h6D: rom_data <= 6'h0B;
            8'h6E: rom_data <= 6'h06;
            8'h6F: rom_data <= 6'h0B;
            8'h70: rom_data <= 6'h03;
            8'h71: rom_data <= 6'h0D;
            8'h72: rom_data <= 6'h07;
            8'h73: rom_data <= 6'h07;
            8'h74: rom_data <= 6'h0B;
            8'h75: rom_data <= 6'h04;
            8'h76: rom_data <= 6'h13;
            8'h77: rom_data <= 6'h02;
            8'h78: rom_data <= 6'h0D;
            8'h79: rom_data <= 6'h13;
            8'h7A: rom_data <= 6'h03;
            8'h7B: rom_data <= 6'h28;
            8'h7C: rom_data <= 6'h28;
            8'h7D: rom_data <= 6'h35;
            8'h7E: rom_data <= 6'h0B;
            8'h7F: rom_data <= 6'h02;
            8'h80: rom_data <= 6'h39;
            8'h81: rom_data <= 6'h35;
            8'h82: rom_data <= 6'h10;
            8'h83: rom_data <= 6'h10;
            8'h84: rom_data <= 6'h04;
            default: rom_data <= 6'h00;
        endcase
    end
`endif

endmodule
