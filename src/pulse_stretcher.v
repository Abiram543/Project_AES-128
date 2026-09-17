module pulse_stretcher(
    input wire clkA, rstnA, clkB, rstnB,
    input wire Din,
    output wire Dout
);

DFF #(.ADDR_WIDTH(1)) inst1(.clk(clkA), .rstn(rstnA), .Din(Din), .Q(W1));
DFF #(.ADDR_WIDTH(1)) inst2(.clk(clkA), .rstn(rstnA), .Din(W1), .Q(W2));
DFF #(.ADDR_WIDTH(1)) inst3(.clk(clkA), .rstn(rstnA), .Din(W2), .Q(W3));
assign W4 = W1 ^ W2 ^ W3;
DFF #(.ADDR_WIDTH(1)) inst4(.clk(clkA), .rstn(rstnA), .Din(W4), .Q(W5));
DFF #(.ADDR_WIDTH(1)) inst5(.clk(clkB), .rstn(rstnB), .Din(W5), .Q(Dout));


endmodule