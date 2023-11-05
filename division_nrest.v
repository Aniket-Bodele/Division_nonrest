`timescale 1ns/1ps
module Division_nrestoring (lda,ldm,ldq,a_0,a_1,clra,sfta,sftq,eqz,ldent,clk,data_in,decr,q0,q1,add,sub);
input lda,ldm,ldq,clra,sfta,sftq,clk,ldent,decr;
parameter N=3;
input [N-1:0] data_in;
input q0,q1,add,sub;
output eqz;
output a_0,a_1;
wire [N-1:0] A,M,Z,Q;
wire [N-1:0] count;
assign eqz= ~|count;
shiftreg1 Ac (A,Z,sfta,clra,Q[N-1],clk,add,sub);
compareA  A_c(a_0,a_1,A);
shiftreg2 Qc (Q,data_in,q0,q1,ldq,sftq,clk);
PIPO Mul (M,data_in,ldm,clk);
ALU Sub (Z,A,M,add,sub);
Counter c (count,decr,ldent,clk);
endmodule
module shiftreg1 (out,in,sft,clr,s_in,clk,add,sub);
input s_in,clk,clr,sft,add,sub;
parameter N=3;
input [N-1:0] in;
output reg [N-1:0] out;
always @(posedge clk)
begin
if(sft) out<={out[N-2:0],s_in};
else if(clr) out<=0;
else if(sub && !add || !sub && add) out<=in;
end
endmodule
module compareA (a_0,a_1,A);
parameter N=3;
input [N-1:0] A;
output reg a_0,a_1;
always @(*)
begin
    if(!A[N-1]) 
    begin
        a_0<=1;a_1<=1;
    end
    else begin
        a_0<=0;a_1<=0;
    end
end
endmodule
module shiftreg2 (out,in,q0,q1,ld,sft,clk);
input ld,clk,sft;
parameter N=3;
input q0,q1;
input [N-1:0] in;
output reg [N-1:0] out;
always @(posedge clk)
begin
    if(sft) out<=out<<1;
    else if(!q0 && q1) out<={out[N-1:1],1'b1};
    else if(q0 && !q1) out<={out[N-1:1],1'b0};
    else if(ld) out<=in;
end
endmodule
module PIPO (out,in,ld,clk);
parameter N=3;
input ld,clk;
input [N-1:0] in;
output reg [N-1:0] out;
always @(posedge clk)
if(ld) out<=in;
endmodule
module ALU (out,in1,in2,add,sub);
parameter N=3;
input [N-1:0] in1,in2;
output reg [N-1:0]out;
input add,sub;
always @(*)
begin
    if(sub && !add) begin out<=in1-in2; end 
    else if(add && !sub) begin out<=in1+in2; end    
end
endmodule
module Counter (data_out,decr,ldent,clk);
parameter N=3;
    input decr,clk,ldent;
    output reg [N-1:0] data_out;
    always @(posedge clk)
    begin
        if(ldent) data_out<=N;
        else if(decr) data_out<=data_out-1;
    end
endmodule
module Controller (lda,ldm,ldq,a_0,a_1,clra,sfta,sftq,eqz,ldent,clk,decr,q0,q1,add,sub,start,done);
input clk, start,eqz;
input a_0,a_1;
output reg lda,ldm,ldq,clra,sfta,sftq,ldent,decr,done;
output reg q0,q1,add,sub;
reg [3:0] state;
parameter s0=4'b0000, s1=4'b0001,s2=4'b0010,s3=4'b0011,s4=4'b0100,s5= 4'b0101,s6=4'b0110,s7=4'b0111,s8=4'b1000,s9=4'b1001,s10=4'b1010,s11=4'b1011,s12=1100;
always @(posedge clk)
begin
    case (state)
        s0: if(start) state<=s1;
        s1:state<=s2;
        s2:if(a_0 && a_1) state<=s3;
           else if(!a_0 && !a_1)state<=s4;
        s3:state<=s5;
        s4:state<=s5;
        s5:if(a_0 && a_1) state<=s6;
           else if(!a_0 && !a_1)state<=s7;
        s6:state<=s8;
        s7:state<=s8;
        s8:state<=s9;
        s9:#2 if(!eqz) state<=s2;
              else state<=s10;
        s10:if(a_0 && a_1) state<=s12;
           else if(!a_0 && !a_1) state<=s11;
        s11:state<=s12;
        s12:state<=s12;

        default: state<=s0;
    endcase
end
always @(state)
begin
    case (state)
        s0: begin
            ldm=0;ldq=0;clra=0;sfta=0;sftq=0;ldent=0;decr=0;done=0;sfta=0;sftq=0;lda=0;
        end
        s1:begin
            ldm=0;ldq=1;clra=1;sfta=0;sftq=0;ldent=1;decr=0;done=0;q0=0;q1=0;sfta=0;sub=0;lda=0;
        end
        s2:begin
            ldm=1;ldq=0;sfta=1;sftq=1;ldent=0;decr=0;done=0;clra=0;q0=0;q1=0;add=0;sub=0;lda=0;
        end
        s3:begin
            ldm=0;ldq=0;sfta=0;sftq=0;ldent=0;decr=0;done=0;clra=0;add=0;sub=1;q0=0;q1=0;lda=0;
        end
        s4:begin
            ldm=0;ldq=0;sfta=0;sftq=0;ldent=0;decr=0;done=0;clra=0;add=1;sub=0;q0=0;q1=0;lda=0;
        end
        s5:begin
            ldm=0;ldq=0;sfta=0;sftq=0;ldent=0;decr=0;done=0;clra=0;add=0;sub=0;q0=0;q1=0;lda=0;
         end
        s6:begin
            ldm=0;ldq=0;sfta=0;q0=0;q1=1;sftq=0;ldent=0;decr=0;done=0;clra=0;add=0;sub=0;lda=0;
        end
        s7: begin ldm=0;ldq=0;sfta=0;sftq=0;ldent=0;decr=0;done=0;q0=1;q1=0;add=0;sub=0;lda=0;
        end
        s8:begin ldm=0;ldq=0;sfta=0;sftq=0;ldent=0;decr=1;done=0;q0=0;q1=0;add=0;sub=0;lda=0;
        end
        s9:begin ldm=0;ldq=0;sfta=0;sftq=0;ldent=0;decr=0;done=0;q0=0;q1=0;add=0;sub=0;lda=0;
        end
        s10:begin ldm=0;ldq=0;sfta=0;sftq=0;ldent=0;decr=0;done=0;q0=0;q1=0;add=0;sub=0;lda=0;
        end
        s11:begin ldm=0;ldq=0;sfta=0;sftq=0;ldent=0;decr=0;done=0;q0=0;q1=0;add=1;sub=0;lda=0;
        end
        s12:begin done=1;
        end
        default:begin
            clra=0;sfta=0;ldq=0;sftq=0;done=0;
        end  
    endcase

end
    
endmodule