`timescale 1ns / 1ps

module RAM
  #()
  (
  input W,
  input clk, 
  input [11:0] addr,
  inout [15:0] data
  );
  // initial mem
  reg [15:0] mem [1 << 12 - 1 : 0];
  // data has two modes --> driven by mem / driven by input
  // we assign data if W is 1 else we just give it a high z value 
  // this way we can drive the input value to data wire , if W is 0

  assign data = W ? 16'bz : mem[addr];
  
  // this saved data whenever W is 1
  always @(posedge clk)begin
    if (W) mem[addr] <= data;
    
  end
  
endmodule

module TB() ;
  // regular wire/reg initial
  reg W;
  reg clk;
  wire [15:0] data; 
  reg [11:0] addr; 
  
  // driver to the inout wire
  reg [15:0] driver;
  
  // assign the driver if we need to give it a input
  assign data  = W ? driver : 16'bz;
  
  // use the module vreated
  RAM R01(.W(W), .clk(clk) ,.data(data) ,.addr(addr));

  // initial of the clock 
  always #5 clk = ~clk;
  
  initial begin 
    $dumpfile("vcd.vcd");
    $dumpvars(0, TB);
    
    clk = 0;
    W = 0;
    addr = 0;
    driver = 0;
        
    $monitor("write value : %d\ninput/output value : %d\naddres value : %d" ,W ,data ,addr);  

    #10 
     $display("writing some values");
    W <= 1;
    addr <= 100;
    driver = 200;
    

    #10
    W <= 1;
    addr <= 200;
    driver = 100;
    
    #10
    W <= 1;
    addr <= 300;
    driver = 300;
  
   
    #10 
    $display("read some values");
    W <= 0;
    addr <= 200;
    driver = 0;
    
    #10
    W <= 0;
    addr <= 100;
    
    #10 
    W <= 0;
    addr <= 400;
    
    
 
    #10
    $display("overwrite and write some other values");
    
    W <= 1;
    addr <= 300;
    driver = 400;
    
    #10
    W <= 1;
    addr <= 400;
    driver = 300;
    
    #10
    W <= 1;
    addr <= 500;
    driver = 500;
    
    #10
    $display("read some values");
    W <= 0;
    addr <= 500;
    
    #10
    W <= 0;
    addr <= 300;

    #10
    W <= 0;
    addr <= 400;
    
    #20000
    $finish ;
  end
  
endmodule 
  
