`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Virginia Tech
// Engineer: Naarayanan Rao VS
// 
// Create Date: 05/01/2020 02:35:32 PM
// Design Name: Round Robin 4-way Bus Arbiter
// Module Name: rr_bus_arbiter
// Project Name: Electronic Design Automation - Lab 3
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: References: http://www.asic-world.com/examples/verilog/arbiter.html
// 
//////////////////////////////////////////////////////////////////////////////////

module rr_bus_arbiter (
  clk,    
  reset,    
  request3,   
  request2,   
  request1,   
  request0,   
  grant3,   
  grant2,   
  grant1,   
  grant0   
);
// --------------Port Declaration----------------------- 
input           clk;    
input           reset;    
input           request3;   // Request 1 of CPU 1
input           request2;   // Request 1 of CPU 1
input           request1;   // Request 1 of CPU 1
input           request0;   // Request 1 of CPU 1
output          grant3;   	// Grant 1 to CPU 1
output          grant2;   // Grant 2 to CPU 2
output          grant1;   // Grant 3 to CPU 3
output          grant0;   // Grant 4 to CPU 4

//--------------Internal Registers----------------------
wire    [1:0]   grant       ;   
wire            comrequest    ;
wire            beg       ;
wire   [1:0]    lgrant      ;
wire            lcomrequest   ;
reg             lgrant0     ;
reg             lgrant1     ;
reg             lgrant2     ;
reg             lgrant3     ;
reg             lasmask   ;
reg             lmask0    ;
reg             lmask1    ;
reg             ledge     ;

//--------------Code Starts Here----------------------- 
always @ (posedge clk)
if (reset) begin
  lgrant0 <= 0;
  lgrant1 <= 0;
  lgrant2 <= 0;
  lgrant3 <= 0;
end else begin                                     
  lgrant0 <=(~lcomrequest & ~lmask1 & ~lmask0 & ~request3 & ~request2 & ~request1 & request0)
        | (~lcomrequest & ~lmask1 &  lmask0 & ~request3 & ~request2 &  request0)
        | (~lcomrequest &  lmask1 & ~lmask0 & ~request3 &  request0)
        | (~lcomrequest &  lmask1 &  lmask0 & request0  )
        | ( lcomrequest & lgrant0 );
  lgrant1 <=(~lcomrequest & ~lmask1 & ~lmask0 &  request1)
        | (~lcomrequest & ~lmask1 &  lmask0 & ~request3 & ~request2 &  request1 & ~request0)
        | (~lcomrequest &  lmask1 & ~lmask0 & ~request3 &  request1 & ~request0)
        | (~lcomrequest &  lmask1 &  lmask0 &  request1 & ~request0)
        | ( lcomrequest &  lgrant1);
  lgrant2 <=(~lcomrequest & ~lmask1 & ~lmask0 &  request2  & ~request1)
        | (~lcomrequest & ~lmask1 &  lmask0 &  request2)
        | (~lcomrequest &  lmask1 & ~lmask0 & ~request3 &  request2  & ~request1 & ~request0)
        | (~lcomrequest &  lmask1 &  lmask0 &  request2 & ~request1 & ~request0)
        | ( lcomrequest &  lgrant2);
  lgrant3 <=(~lcomrequest & ~lmask1 & ~lmask0 & request3  & ~request2 & ~request1)
        | (~lcomrequest & ~lmask1 &  lmask0 & request3  & ~request2)
        | (~lcomrequest &  lmask1 & ~lmask0 & request3)
        | (~lcomrequest &  lmask1 &  lmask0 & request3  & ~request2 & ~request1 & ~request0)
        | ( lcomrequest & lgrant3);
end 

//----------------------------------------------------
// lasmask state machine.
//----------------------------------------------------
assign beg = (request3 | request2 | request1 | request0) & ~lcomrequest;
always @ (posedge clk)
begin                                     
  lasmask <= (beg & ~ledge & ~lasmask);
  ledge   <= (beg & ~ledge &  lasmask) 
          |  (beg &  ledge & ~lasmask);
end 

//----------------------------------------------------
// comrequest logic.
//----------------------------------------------------
assign lcomrequest = ( request3 & lgrant3 )
                | ( request2 & lgrant2 )
                | ( request1 & lgrant1 )
                | ( request0 & lgrant0 );

//----------------------------------------------------
// Encoder logic.
//----------------------------------------------------
assign  lgrant =  {(lgrant3 | lgrant2),(lgrant3 | lgrant1)};

//----------------------------------------------------
// lmask register.
//----------------------------------------------------
always @ (posedge clk )
if( reset ) begin
  lmask1 <= 0;
  lmask0 <= 0;

end else if(lasmask) begin
  lmask1 <= lgrant[1];
  lmask0 <= lgrant[0];
end else begin
  lmask1 <= lmask1;
  lmask0 <= lmask0;
end 

assign comrequest = lcomrequest;
assign grant    = lgrant;
//----------------------------------------------------
// Drive the outputs
//----------------------------------------------------
assign grant3   = lgrant3;
assign grant2   = lgrant2;
assign grant1   = lgrant1;
assign grant0   = lgrant0;

//Checks whether the reset deasserts all the grant signals

reset: assert property(reset |=> !(grant0 | grant1 | grant2 | grant3));

//Checking for a Liveness property: Eventually the request is allowed to access the memory bus in the corresponding 4 cycles.

accessrequest: assert property(reset == 0 && request0 == 1 |-> ##[1:3] lgrant0 == 1);   

//Checking the safety property: No two grants are issued together to avoid deadlock.

one_grant: assert property(!reset && lgrant0 == 1 |-> (grant1 || grant2 || grant3) == 0);

//Checks whether if a request is deasserted, the corresponding grant is also asserted or not. 

no_grant: assert property(!reset && request0 == 0 |-> ##[1:3] grant1 == 0);

// Checks whether there are no grants when requestuests are not there in the future cycles

norequest_noGrant: assert property(!reset && !(request0 || request1 || request2 || request) |-> ##[0:3] !(lgrant0 || lgrant1 || lgrant2 || lgrant3));

//Checks whether only one request gets a grant when other requests are deasserted 

onereq_onegrant: assert property(!reset && request == 1 && (request1 || request2 || request3) == 0 |=> grant0 == 1 && (grant1 || grant2 || grant3));

endmodule  //rr_bus_arbiter




//assert_only1_grant: assert property(grant1 == 1 |-> !(grant2 || grant3 || grant0));