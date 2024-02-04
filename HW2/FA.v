module TESTBENCH;
  initial 
  begin
    $dumpfile("waveforms.vcd");
    $dumpvars(0,TESTBENCH);
  end
  reg [3:0] NUM1;
  reg [3:0] NUM2;
  reg CIN; 
  wire [3:0] SUM;
  wire COUT;
  FourBitRCA rca(NUM1, NUM2, CIN, SUM, COUT);
  initial 
  begin
    # 10
    NUM1 = 4'b1001; 
    NUM2 = 4'b0110; 
    CIN = 1'b1;
  end  
endmodule

module FourBitRCA(NUM1,NUM2,CIN,SUM,COUT);
  input [3:0] NUM1;
  input [3:0] NUM2;
  input CIN;
  output [3:0] SUM;
  output COUT;
  wire C0,C1,C2;
  
  FA fa1(NUM1[0],NUM2[0],CIN,SUM[0],C0);
  FA fa2(NUM1[1],NUM2[1],C0,SUM[1],C1);
  FA fa3(NUM1[2],NUM2[2],C1,SUM[2],C2);
  FA fa4(NUM1[3],NUM2[3],C2,SUM[3],COUT);
endmodule

module HA (NUM1,NUM2,SUM,COUT);
  input NUM1,NUM2;
  output reg COUT,SUM;
  
  always @(*)
    begin
      #3 case({NUM1,NUM2})
        3'b00: SUM=0;
        3'b01: SUM=1;
        3'b10: SUM=1;
        3'b11: SUM=0;
      default: SUM=0 ; 
      endcase 
  end    
  always @(*)
    begin
        #2 case({NUM1,NUM2})
        3'b00: COUT=0;
        3'b01: COUT=0;
        3'b10: COUT=0;
        3'b11: COUT=1;
      default: COUT=0 ; 
      endcase   
    end 
endmodule

module FA(NUM1,NUM2,CIN,SUM,COUT);
  input NUM1, NUM2, CIN;
  output COUT,SUM;
  
  wire SUM1;
  wire CARRY1;
  wire CARRY2;
  
  HA HA1(NUM1,NUM2,SUM1,CARRY1);
  HA HA2(SUM1,CIN,SUM,CARRY2);
  or(COUT,CARRY1,CARRY2);
  
endmodule


