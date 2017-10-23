#
# Generate control rom for Speech256 project
# 
# Copyright N.A. Moseley 2017 / Moseley Instruments
#
# The control rom is in a slightly different format
# than we need for the Verilog code, so in addition
# to making a ROM directry, we massage it a bit...
#

VerilogHeader = """
// This file was auto-generated,
// do not modify by hand!

module CTRLROM (
        clk, 
        en, 
        addr, 
        data
    );
    input            clk;
    input            en;
    input     [11:0] addr;
    output reg [7:0] data;

    always @(posedge clk)
    begin
        if (en)
            case(addr)
"""

VerilogFooter = """                default: data <= 8'bXXXXXXXX;
            endcase
    end
endmodule
"""

RomAddress = 0;

def emitRomByte(b):
    global RomAddress
    global fout
    fout.write("                12'd"+str(RomAddress)+": data <= 8'd" + str(b) + ";\n")
    RomAddress = RomAddress + 1;

def convertFilterCoeff(c):
    # turn c into negative 8-bit number
    # 1 -> 255
    # 2 -> 254
    # 255 -> 1
    # 254 -> 2
    # 128 -> xxx
    # 0   -> 0
    
    return c;

fout = open('ctrlrom.v','wt')

with open('ctrlrom.hex', 'r') as fp:
    hex_list = fp.readlines()


cmd_list = [int(c,16) for c in hex_list];

# generate header
fout.write(VerilogHeader)

# generate jump table
for I in range(0,0x7E):
    emitRomByte(cmd_list[I])

counter = 0x7E
while (counter < len(cmd_list)):
    cmd = cmd_list[counter];
    if (cmd == 0):        #  JUMP INSTRUCTION        
        print("?")
    elif (cmd == 1):   # SET AMP AND PITCH
        emitRomByte(cmd)
        emitRomByte(cmd_list[counter+1]) # AMP LSB
        emitRomByte(cmd_list[counter+2]) # AMP MSB
        emitRomByte(cmd_list[counter+3]) # DUR
        emitRomByte(cmd_list[counter+4]) # PITCH
        counter = counter + 4
        #print("SET AMP+PITCH")
    elif (cmd == 2):   # SET COEFFICIENTS
        emitRomByte(cmd)
        emitRomByte(cmd_list[counter+1]) # AMP LSB
        emitRomByte(cmd_list[counter+2]) # AMP MSB
        emitRomByte(cmd_list[counter+3]) # DUR
        emitRomByte(cmd_list[counter+4]) # PITCH
        emitRomByte(convertFilterCoeff(cmd_list[counter+10])) # F6
        emitRomByte(convertFilterCoeff(cmd_list[counter+10+6])) # B6
        emitRomByte(convertFilterCoeff(cmd_list[counter+9])) # F5
        emitRomByte(convertFilterCoeff(cmd_list[counter+9+6])) # B5        
        emitRomByte(convertFilterCoeff(cmd_list[counter+8])) # F4
        emitRomByte(convertFilterCoeff(cmd_list[counter+8+6])) # B4        
        emitRomByte(convertFilterCoeff(cmd_list[counter+7])) # F3
        emitRomByte(convertFilterCoeff(cmd_list[counter+7+6])) # B3        
        emitRomByte(convertFilterCoeff(cmd_list[counter+6])) # F2
        emitRomByte(convertFilterCoeff(cmd_list[counter+6+6])) # B2        
        emitRomByte(convertFilterCoeff(cmd_list[counter+5])) # F1
        emitRomByte(convertFilterCoeff(cmd_list[counter+5+6])) # B1        
        counter = counter + 4 + 12
        #print("SET COEFFS")
    elif (cmd == 15):   # SET COEFFICIENTS: # END OF COMMAND / 15
        emitRomByte(cmd)
    else:
        print("*** ERROR ***")
        break
    counter = counter + 1

# generate footer
fout.write(VerilogFooter)

fout.close()