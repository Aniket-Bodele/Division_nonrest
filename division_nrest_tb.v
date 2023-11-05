`timescale 1ns/1ps
`include"division_nrest.v"
module Division_test ;
parameter N=3;
reg [N-1:0] data_in; 
reg clk,start;
wire done;
Division_nrestoring  DN (lda,ldm,ldq,a_0,a_1,clra,sfta,sftq,eqz,ldent,clk,data_in,decr,q0,q1,add,sub);
Controller CN (lda,ldm,ldq,a_0,a_1,clra,sfta,sftq,eqz,ldent,clk,decr,q0,q1,add,sub,start,done);
initial
begin
    clk=1'b0;
    #3 start=1'b1;
    #600 $finish;
end
always #5 clk=~clk;  
initial
begin
    #17 data_in=3'b111;
    #10 data_in=3'b011;
end
initial
begin
    
    $dumpfile("non_rest_division.vcd");$dumpvars(0,Division_test);
end
    
endmodule