// 
// Very simple, i.e. 8-bit non noise-shaping pulse-width modulation (PWM) DAC.
// The DAC has a pull interface.
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//
//
// For a 10 kHz output rate, the clock rate should be 2.560 MHz
// 

module PWMDAC (
        clk, 
        rst_an, 
        din,        // 16 bit signed data input
        din_ack,    // is high for 1 clock cycle after reading the din signal
        dacout      // 1-bit PWM output signal
    );

	//////////// CLOCK //////////
	input clk;

    //////////// RESET, ACTIVE LOW //////////
    input rst_an;

	//////////// DAC OUTPUT //////////
	output reg dacout;

	//////////// DATA BUS //////////
	input signed [7:0] din;
    output reg din_ack;             // is high for 1 clock cycle after reading the din signal

    // internal counter and data registers
    reg signed [7:0] counter;
    reg signed [7:0] data;

    // pre-emphasis filter
    reg signed [7:0]   last_data;
    reg signed [10:0]  sum1r_d;
    reg signed [10:0]  sum1r;
    wire signed [10:0] sum1;
    wire signed [13:0] sum2;
    reg signed [7:0]  quantdata;

    assign sum1 = $signed({data[7] ,{data, 2'b00}}) + data   - $signed({last_data, 2'b00});
    assign sum2 = $signed({sum1r[10],{sum1r, 2'b00}}) + sum1r - $signed({sum1r_d, 2'b00});

    // output saturation
    always @(*)
    begin        
        if (sum2[13] ^ sum2[12] != 0)
        begin
            // saturation needed
            quantdata = sum2[13] ?  8'h80 : 8'h7F;
        end
        else 
            quantdata = sum2[12:5];
    end

    always @(posedge clk, negedge rst_an)
    begin
        if (rst_an == 0)
        begin
            // reset values
            counter <= 0;
            dacout  <= 0;
            din_ack <= 0;
            data    <= 0;
        end
        else
        begin
            // increment counter
            counter <= counter + 8'b00000001;

            // compare counter with data 
            // and set output accordingly.
            if (quantdata > counter)
                dacout <= 1;
            else
                dacout <= 0;

            // load new data into DAC when
            // counter is 127
            if (counter == 8'h7F)
            begin
                sum1r   <= sum1;
                sum1r_d <= sum1r;
                last_data <= data;
                data <= din;
                din_ack <= 1;        
            end
            else
                din_ack <= 0;            
        end
    end
endmodule
