
// with help of : https://github.com/parnabghosh1004/Floating-Point-ALU/blob/master/mul.v


`timescale 1ns / 1ns
module FloatingPointMult
#(
// just added this section to specify that we are using IEEE
// my code parameters cant be changed and it is constant valued 
parameter nb = 32,
parameter exponent = 8,
parameter fraction = 23
)
(
    input [31:0] a, // input1
    input [31:0] b, // input2
    output [31:0] result, // output
    output NAN, //  flag for NAN
    output INF, // flag for INF
    output OF, // flag for overflow
    output UF // flag for underflow
);

wire [8:0] final_exponent;
wire [22:0] final_mantissa; 
wire [23:0] final_a; // we creat a new a ,in format of 0.xxxx or 1.xxxx (depends on denormalized or normalized format)
wire [23:0] final_b; // same here
wire [47:0] normalized_mantissa_mult_result;
wire [47:0] mantissa_mult_result;
wire final_sign;
wire reduced_or_exponent1;
wire reduced_and_exponent1;
wire reduced_or_exponent2;
wire reduced_and_exponent2;
wire reduced_or_fraction1;
wire reduced_or_fraction2;
wire rounding_bit; // for rounding 
wire normal_bit; // for normalizing
wire zero_bit; // in case of zero input

// xor sign1 ,sign2 = sign3
assign final_sign = a[31] ^ b[31];        
// in case we have a NAN or inf number (exponent = 8{1})
assign reduced_and_exponent1 = &a[30:23];
assign reduced_and_exponent2 = &b[30:23];
// check if there is a error , is it a NAN or is it a INF (frsc == 0 or frac != 0)
assign reduced_or_fraction1 = |a[22:0];
assign reduced_or_fraction2 = |b[22:0];
// check for NAN - INF - Zero inputs
// assgn NAN_INF flags and zero wire
assign NAN = (reduced_and_exponent1 & reduced_or_fraction1) | (reduced_and_exponent2 & reduced_or_fraction2);
assign INF = (reduced_and_exponent1 & (!reduced_or_fraction1)) | (reduced_and_exponent2 & (!reduced_or_fraction2));
assign zero_bit = (!(|a[30:0])) | (!(|b[30:0]));

// check for denormalize and create 1.xxxx or 0.xxxx
assign reduced_or_exponent1 = |a[30 : 23];
assign reduced_or_exponent2 = |b[30 : 23];   
assign final_a = {reduced_or_exponent1,a[22 :0]} ;
assign final_b = {reduced_or_exponent2,b[22 :0]} ; 
assign mantissa_mult_result = final_a * final_b; 
// normalization bit
assign normal_bit = mantissa_mult_result[47] ;
// here we are conditioning our fraction for two cases --> if normal_bit == 1 or else
// if normal_bit : no need to shift and we should add 1 to exp
// else : shift one bit to left
assign normalized_mantissa_mult_result = mantissa_mult_result << (!normal_bit);
// for rounding -> if the last 24 bits has a format of  1xxxxxxxx --> we delete them and add a {1,24{0}) to it
assign round_bit = normalized_mantissa_mult_result[23] & (|normalized_mantissa_mult_result[23:0]); 
assign final_mantissa = normalized_mantissa_mult_result[46 :24] + round_bit ;   
// getting final exp + comment on line 55
// we subtract bias (127) to tune the exponent 
assign final_exponent = a[30 :23] + b[30 :23] + normal_bit - 127;
// we added not (zero/ inf / nan) for making the flags more accurate
assign OF = final_exponent[8] & (!final_exponent[7]) & (!zero_bit) & (!NAN) & (!INF);
assign UF = final_exponent[8] & final_exponent[7] & (!zero_bit) & (!NAN) & (!INF);
// here we could program result with case , for clean code
// but i was more comfortable with assign and ? : expression  
// we handeled different cases as below : 
// we are giving 32'bx value in case of OF and UF 
// we could also give something like infinity or zero for these cases
// (if the flag OF is set --> give out INF value and if the flag UF is set --> give out zero value)
// we assumed zero * something = zero
// we assumed inf * something non zero = inf
assign result = zero_bit ? {final_sign ,31'b0} : NAN ? { final_sign ,8'b11111111 ,23'bx } : INF ? {final_sign ,8'b11111111 ,23'b0 } : OF ? { 32'bx } : UF ? {32'bx } : { final_sign ,final_exponent[7:0] ,final_mantissa };

endmodule
   
module TB();
  reg [31:0] n1, n2;
  wire of , uf , nan , inf;
  wire [31:0] result;

FloatingPointMult fpm01(
  .a(n1),
  .b(n2),
  .result(result),
  .OF(of),
  .UF(uf),
  .INF(inf),
  .NAN(nan)
);

initial begin
    $dumpfile("FPM.vcd");
    $dumpvars(0,TB);

  
  // calculated the inputs from site http://weitz.de/ieee/
  $display("ans1 is : 00000000000000000000000000000000 (type : one number is zero)");
  $display("ans2 is : 011111111xxxxxxxxxxxxxxxxxxxxxxx (type : one number is NAN)");
  $display("ans3 is : 01111111100000000000000000000000 (type : one number is INF)");
  $display("ans4 is : 01001011010101010101010101010100");
  $display("ans5 is : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (type : overflow)");
  $display("ans6 is : 00111111111110001001100000101110");
  $display("ans7 is : 01000100110110101011110110000110");
  $display("ans8 is : 01000101100101011110011101001010");
  $display("ans9 is : 01001110001111000101101000010000");
  $display("ans10 is : xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (type : overflow)");
  
  $display("------------------- calculating -------------------");

    
  $monitor ("n1 is %b \nn2 is %b \nthe result given by our FPM is %b \nour OF signal : %b \nour UF signal : %b \nour NAN signal : %b \nour INF signal : %b" ,n1 ,n2 ,result ,of ,uf ,nan ,inf);


  // one of them zero.
  n1 = 32'b0;
  n2 = 32'b01000010101110111010001101111111;
  # 20;
  $display("                    **********************************                    ");
  // one of them not a number
  n1 = 32'b01111111100101010101010101010101;
  n2 = 32'b01000010101110111010001101111111;
  # 20;
  $display("                    **********************************                    ");
  // one of them is INF
  n1 = 32'b01111111100000000000000000000000;
  n2 = 32'b01000010101110111010001101111111;
  # 20;
  $display("                    **********************************                    ");
  // normal multiplications (may have OF / UF) 
  n1 = 32'b00110101011111111111111111111111;
  n2 = 32'b01010101010101010101010101010101;
  # 20;
  $display("                    **********************************                    ");

  n1 = 32'b01110101011111111111111111111111;
  n2 = 32'b01110101010101010101010101010101;
  # 20;
  $display("                    **********************************                    ");
  
  n1 = 32'b00111111101001000100100010110000;
  n2 = 32'b00111111110000011011000010001010;
  # 20;
  $display("                    **********************************                    ");
    
  n1 = 32'b01000010000000010100110011100111;
  n2 = 32'b01000010010110001000101001011000;
  # 20;
  $display("                    **********************************                    ");
  
  n1 = 32'b01000010101100010011100001010010;
  n2 = 32'b01000010010110001000101001011000;
  # 20;
  $display("                    **********************************                    ");
  
  n1 = 32'b01000111000001010100110000000000;
  n2 = 32'b01000110101101001101111000000000;
  # 20;
  $display("                    **********************************                    ");
  
  n1 = 32'b11111111011111010101001111110101;
  n2 = 32'b01111111011111010101001111110101;
  # 20;

end

endmodule

