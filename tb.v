`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2020 05:42:35 PM
// Design Name: 
// Module Name: tb
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

module tb();

reg clk;
reg req0;
reg req1;
reg req2;
reg req3;
reg rst_an;

rr_arbiter dut (
	.req({req3,req2,req1,req0}),
	.grant({grant3,grant2,grant1,grant0}),
	.clk(clk),
	.rst_an(rst_an)
);

initial
begin
	clk = 0;
	req3 = 0;
	req2 = 0;
	req1 = 0;
	req0 = 0;
	rst_an = 1'b1;
	#10 rst_an = 0;
	#10 rst_an = 1;
	repeat (1) @ (posedge clk);
	req0 <= 1;
	repeat (1) @ (posedge clk);
	req0 <= 0;
	repeat (1) @ (posedge clk);
	req0 <= 1;
	req1 <= 1;
	repeat (1) @ (posedge clk);
	req2 <= 1;
	req1 <= 0;
	repeat (1) @ (posedge clk);
	req3 <= 1;
	req2 <= 0;
	repeat (1) @ (posedge clk);
	req3 <= 0;
	repeat (1) @ (posedge clk);
	req0 <= 0;
	repeat (1) @ (posedge clk);
	#10  $finish;

end

always	#1 clk = ~clk;
endmodule
