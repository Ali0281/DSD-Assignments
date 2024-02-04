`timescale 1ns / 1ps

module ALU
    #(
        // parameter for the data width
        parameter nb = 16
    )
    (
        // n for input
        // c for control
        // acc register & output
        // flags
        input [nb - 1 : 0] n,
        input [2 : 0] c,
        input clk,
        output reg [nb - 1 : 0] acc,
        output reg C,
        output Z,
        output reg V,
        output S
    ); 
    // temp reg
    reg [nb : 0] temp_reg; 
    // assign wire flags
    assign Z = ~(|acc[nb - 1 : 0]);
    assign S = acc[nb - 1];



    // we handeled sub and add overflow as below : 
    // in addition : if we have a + + sign we should get a + sign ans 
    // we have the same thing in - - case
    // but in the - + or + - case the result sign is unknown 
    // so we said that if our ans sign is not equal to non of the input signs so we have OF
    // in subtraction :  
    // we have the same thing but the unknow results are in case + + and - -
    // and the known cases are + - and - + that the result sign should be + and -(in order)
    // so we checked that if sign res is not equal to fisrt one and equal to second one 
    always @(posedge clk) begin
        // test diffrent cases
        case (c)
        3'b000 : begin
            // hold 
            acc = acc;
            V = 0;
            C = 0;
        end
        3'b001 : begin
            // clear
            acc = 0;
            V = 0;
            C = 0;
            
        end
        3'b010 : begin
            // add
            temp_reg = acc + n;
            if ((temp_reg[nb-1] != acc[nb-1]) & (temp_reg[nb-1] != n[nb-1])) 
		V = 1;
	    else
		V = 0;
	    C = temp_reg[nb];
            acc = temp_reg[nb - 1 : 0];
        end
        3'b011 : begin
            // subtract
            temp_reg = acc - n;
	    if ((temp_reg[nb-1] != acc[nb-1]) & (temp_reg[nb-1] == n[nb-1]))
		V = 1;
	    else 
		V = 0;          
            C = !temp_reg[nb];
            acc = temp_reg[nb - 1 : 0];
            
        end
        3'b100 : begin
            // and
            acc = acc & n;
            V = 0;
            C = 0;
        end
        3'b101 : begin
            // neg
            acc = -acc;
            V = 0;
            C = 0;
        end
        3'b110 : begin
            // not
            acc = ~acc;
            V = 0;
            C = 0;
        end
        3'b111 : begin
            // xor
            acc = acc ^ n;
            V = 0;
            C = 0;
        end
        endcase
    end
endmodule


module TB();
    reg clk;
    reg [15:0]in;
    reg [2:0]control;
    wire [15:0]out;
    wire c;
    wire z;
    wire v;
    wire s;

    ALU #(16) ALU01(
        .n(in) ,
        .c(control) ,
        .clk(clk) ,
        .acc(out) ,
        .C(c) ,
        .Z(z) ,
        .V(v) ,
        .S(s)
    );

    always #5 clk = ~clk; 
    initial begin
        $dumpfile("vcd.vcd");
        $dumpvars(0, TB);

        clk = 0;
        in = 0;
        control = 0;
        
        $display("clear acc");
        control <= 3'b001;
        in <= 16'd120;
        #10;
        $display("out is (B - D): %b - %d\nCarry: %d\nZero: %d\nOverflow: %d\nSign : %d",out ,out ,c ,z ,v ,s);
        

        $display("add value 100");
        control <= 3'b010;
        in <= 16'd100;
        #10;
        $display("out is (B - D): %b - %d\nCarry: %d\nZero: %d\nOverflow: %d\nSign : %d",out ,out ,c ,z ,v ,s);
        

        $display("hold a value in acc");
        control <= 3'b000;
        in <= 16'd120;
        #10;
        $display("out is (B - D): %b - %d\nCarry: %d\nZero: %d\nOverflow: %d\nSign : %d",out ,out ,c ,z ,v ,s);


        $display("sub value 50");
        control <= 3'b011;
        in <= 16'd50;
        #10;
        $display("out is (B - D): %b - %d\nCarry: %d\nZero: %d\nOverflow: %d\nSign : %d",out ,out ,c ,z ,v ,s);
        

        $display("and value with 31");
        control <= 3'b100;
        in <= 16'd31;
        #10; 
        $display("out is (B - D): %b - %d\nCarry: %d\nZero: %d\nOverflow: %d\nSign : %d",out ,out ,c ,z ,v ,s);
        

        $display("neg value of acc");
        control <= 3'b101;
        in <= 16'd0;
        #10;
        $display("out is (B - D): %b - %d\nCarry: %d\nZero: %d\nOverflow: %d\nSign : %d",out ,out ,c ,z ,v ,s);
        

        $display("not value of acc");
        control <= 3'b110;
        in <= 16'd0;
        #10;
        $display("out is (B - D): %b - %d\nCarry: %d\nZero: %d\nOverflow: %d\nSign : %d",out ,out ,c ,z ,v ,s);
        

        $display("xor with 15");
        control <= 3'b111;
        in <= 16'd15;
        #10;
        $display("out is (B - D): %b - %d\nCarry: %d\nZero: %d\nOverflow: %d\nSign : %d",out ,out ,c ,z ,v ,s);
      

	$display("now we are going to test OF");
        $display("clear acc");
        control <= 3'b001;
        in <= 16'd120;
        #10;
        $display("out is (B - D): %b - %d\nCarry: %d\nZero: %d\nOverflow: %d\nSign : %d",out ,out ,c ,z ,v ,s);

	$display("add value 1000");
        control <= 3'b010;
        in <= 16'd1000;
        #10;
        $display("out is (B - D): %b - %d\nCarry: %d\nZero: %d\nOverflow: %d\nSign : %d",out ,out ,c ,z ,v ,s); 

	$display("add value max");
        control <= 3'b010;
        in <= 16'b0111_1111_1111_1111;
        #10;
        $display("out is (B - D): %b - %d\nCarry: %d\nZero: %d\nOverflow: %d\nSign : %d",out ,out ,c ,z ,v ,s); 

    end

endmodule