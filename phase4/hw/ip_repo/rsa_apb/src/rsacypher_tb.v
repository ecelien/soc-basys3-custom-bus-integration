`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2023 12:06:54 PM
// Design Name: 
// Module Name: rsacypher_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rsacypher_tb;
    parameter period = 5; // Clock period
    parameter Keysize = 128;
    
    //---Inputs----
    reg                 clk;
    reg                 reset;
    reg                 ds;
    reg [Keysize-1:0]   indata;
    reg [Keysize-1:0]   inExp;
    reg [Keysize-1:0]   inMod;
    
   
    //---Outputs---
    wire        ready;
    wire [Keysize-1:0]   cypher;
    
    //module instantiation
    RSACypher UUT(
        .indata(indata),
	    .inExp(inExp),
	 	.inMod(inMod),
	    .cypher(cypher),
		.clk(clk),
	    .ds(ds),
	    .reset(reset),
		.ready(ready)
    );

    always #(period) clk = !clk;

    
    initial begin
    
        clk     <= 0;
        #period;
        reset   <= 1;
        #(period*4);
        reset   <= 0;
        #period;
        indata  <= 128'h01301228024010285240102817401028;
        inExp   <= 128'h00001500032002040100011900000204;
        inMod   <= 128'h00001027000030237010802700006015;
        ds      <= 1;
        wait(ready == 1);
        $display("Cypher = 0x%h", cypher);
        
        // Expected Cypher = 128'h00000119dd4663892c0c081a2dd3f272;
        $stop;
    end
endmodule
