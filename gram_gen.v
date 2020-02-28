`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/02/25 21:31:53
// Design Name: 
// Module Name: gram_gen
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


module gram_gen#(parameter DIMENSION=4,WIDTH=8)
(clk,rst,en,
H1,H2,H3,
G1,G2,G3
);
input clk,rst,en;
input signed [DIMENSION*WIDTH-1:0] H1,H2,H3;
output reg signed [3*WIDTH-1:0] G1,G2,G3;  //final matrix

reg [3:0] count;

reg [6:0] c_n;
    


wire [WIDTH-1:0] r1[DIMENSION+3:0];
wire [WIDTH-1:0] r2[DIMENSION+3:0];
wire [WIDTH-1:0] r3[DIMENSION+3:0];

wire [WIDTH-1:0] c1[DIMENSION+3:0];
wire [WIDTH-1:0] c2[DIMENSION+3:0];
wire [WIDTH-1:0] c3[DIMENSION+5:0];  //¹²éî×ªÖÃ

wire [WIDTH-1:0] P11;
wire [WIDTH-1:0] P21;
wire [WIDTH-1:0] P22;
wire [WIDTH-1:0] P31;
wire [WIDTH-1:0] P32;
wire [WIDTH-1:0] P33;

assign r2[0]=r2[4];
assign r3[0]=r3[4];
assign r3[1]=r3[5];

assign c2[0]=c2[4];
assign c2[1]=c2[5];

assign c3[0]=c3[4];
assign c3[1]=c3[5];
assign c3[2]=c3[6];
assign c3[3]=c3[7];

genvar i; 
generate
    for(i=0;i<DIMENSION;i=i+1)
       begin:assign_value
       assign r1[i]=H1[(i+1)*WIDTH-1:i*WIDTH];
       assign r2[i+1]=H2[(i+1)*WIDTH-1:i*WIDTH];
       assign r3[i+2]=H3[(i+1)*WIDTH-1:i*WIDTH];
       
       if(i<2)
       begin
       assign c1[i]=H1[(i+1)*WIDTH-1:i*WIDTH];
       assign c2[i+2]=H2[(i+1)*WIDTH-1:i*WIDTH];
       assign c3[i+4]=H3[(i+1)*WIDTH-1:i*WIDTH];
       end
       
       else
       begin
       assign c1[i]=-H1[(i+1)*WIDTH-1:i*WIDTH];
       assign c2[i+2]=-H2[(i+1)*WIDTH-1:i*WIDTH];
       assign c3[i+4]=-H3[(i+1)*WIDTH-1:i*WIDTH];
       end
       
       
        end
        
endgenerate

wire [WIDTH-1:0] data_11t21,data_21t22,data_21t31,data_22t32,data_31t32,data_32t33;

wire ctr_11o,ctr_21o,ctr_22o,ctr_31o,ctr_32o,ctr_33o;

PE_gram PE11(.clk(clk),.rst(rst),.en(en),.in_A(r1[count]),.in_B(c1[count]),.out_A(  ),.out_B(data_11t21),.P(P11),.en_o(ctr_11o));

PE_gram PE21(.clk(clk),.rst(rst),.en(ctr_11o),.in_A(r2[count]),.in_B(data_11t21),.out_A(data_21t22),.out_B(data_21t31),.P(P21),.en_o(ctr_21o));
PE_gram PE22(.clk(clk),.rst(rst),.en(ctr_21o),.in_A(data_21t22),.in_B(c2[count]),.out_A( ),.out_B(data_22t32),.P(P22),.en_o(ctr_22o));

PE_gram PE31(.clk(clk),.rst(rst),.en(ctr_21o),.in_A(r3[count]),.in_B(data_21t31),.out_A(data_31t32),.out_B( ),.P(P31),.en_o(ctr_31o));
PE_gram PE32(.clk(clk),.rst(rst),.en(ctr_31o & ctr_22o),.in_A(data_31t32),.in_B(data_22t32),.out_A(data_32t33),.out_B( ),.P(P32),.en_o(ctr_32o));
PE_gram PE33(.clk(clk),.rst(rst),.en(ctr_32o),.in_A(data_32t33),.in_B(c3[count]),.out_A( ),.out_B( ),.P(P33),.en_o(ctr_33o));



always@(posedge clk)
begin
if(!rst)
count<=0;
else if(en)
 begin
 if(count<DIMENSION-1)
 count<=count+1;
 else 
 begin
 count<=0;
 end
 end
else 
  count<=0;
end

always@(posedge clk)
begin
if(!rst)
c_n<=0;
else if(en)
c_n<=c_n+1;
else
c_n<=0;
end

always@(posedge clk)
begin
if(!rst)
begin
G1<=0;
G2<=0;
G3<=0;
end
else if(en)
    begin
        if(c_n==4)
            begin
                G1[3*WIDTH-1:2*WIDTH]<=P11;
            end
        else if(c_n==5)
            begin
                G2[3*WIDTH-1:2*WIDTH]<=P21; 
                G1[2*WIDTH-1:1*WIDTH]<=-P21;
            end
        else if(c_n==6)
            begin
                 G3[3*WIDTH-1:2*WIDTH]<=P31;
                 G2[2*WIDTH-1:1*WIDTH]<=P22; 
                 G1[1*WIDTH-1:0*WIDTH]<=-P31;
            end
        else if(c_n==7)
            begin
                 G3[2*WIDTH-1:1*WIDTH]<=P32; 
                 G2[1*WIDTH-1:0*WIDTH]<=-P32; 
            end
        else if(c_n==8)
            begin
                G3[1*WIDTH-1:0*WIDTH]<=P33;
            end
        else
            begin
            G1<=0;
            G2<=0;
            G3<=0;
            
            end
    end

else
    begin
        G1<=0;
        G2<=0;
        G3<=0;
    end

end

endmodule
