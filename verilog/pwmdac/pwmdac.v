// 
// Very simple, i.e. 8-bit non noise-shaping pulse-width modulation (PWM) DAC.
// The DAC has a pull interface.
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

module PWMDAC (
        clk, 
        rst_an, 
        din, 
        din_ack, 
        dacout
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
            if (data > counter)
                dacout <= 1;
            else
                dacout <= 0;

            // load new data into DAC when
            // counter is 255
            if (counter == 8'h7F)
            begin
                data <= din;
                din_ack <= 1;        
            end
            else
                din_ack <= 0;
            
        end
    end

endmodule
