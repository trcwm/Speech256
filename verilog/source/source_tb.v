// 
// PWMDAC testbench
//
// Niels Moseley - Moseley Instruments 2017
// http://www.moseleyinstruments.com
//

module SOURCE_TB;
    reg clk, rst_an, strobe; 
    reg signed [14:0] amp;
    reg [7:0] period;

    reg [7:0] cnt;

    wire signed [15:0] source_out;
    wire period_done;

    SOURCE u_source (
        .clk     (clk),
        .rst_an  (rst_an),
        .period  (period),
        .amplitude (amp),
        .strobe  (strobe),
        .period_done (period_done),
        .source_out  (source_out)
    );

    integer fd; // file descriptor

    initial
    begin
        fd = $fopen("audio.sw","wb");
        $dumpfile ("source.vcd");
        $dumpvars;
        clk = 0;
        rst_an = 0;
        strobe = 0;
        period = 50;
        amp    = 15000;
        cnt    = 0;
        #3
        rst_an = 1;
        #300000
        period = 0; // switch to noise mode
        #300000
        $fclose(fd);
        $finish;
    end

    always @(posedge clk)
    begin        
        if (cnt == 4)
        begin
            cnt <= 0;
            strobe <= 1;            
            $fwrite(fd,"%u",{ {16{source_out[15]}} ,source_out});
        end
        else
        begin
            strobe <= 0;
            cnt <= cnt + 1;
        end        
    end

    always
        #5 clk = !clk;

endmodule