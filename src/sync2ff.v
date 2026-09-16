module sync2ff(D,rst,clk,q);
input D,rst,clk;
wire q1;
output q;

DFF d1(D,rst,clk,q1);
DFF d2(q1,rst,clk,q);

endmodule
