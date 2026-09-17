module mux_sync(
    input wire clkA, rstnA, clkB, rstnB,
    input wire ena,
    input wire [127:0] Din,
    output wire [127:0] Dout
);

wire W1;
wire [127:0] W2;

DFF #(.ADDR_WIDTH(1)) inst2(.clk(clkA), .rstn(rstnA), .Din(ena), .Q(W1)); 

ff2_sync #(.ADDR_WIDTH(1)) U1 (.clk(clkB), .rstn(rstnB), .Din(W1), .Sync_out(ena_sync));

always @ (*) begin
    if(ena_sync)
        W2 = Din;
    else
        W2 = Dout;
end

DFF #(.ADDR_WIDTH(128)) inst3(.clk(clkB), .rstn(rstnB), .Din(W2), .Q(Dout)); 

endmodule

module ff2_sync #(parameter ADDR_WIDTH = 5)(
        input wire clk, rstn,
        input wire [ADDR_WIDTH-1:0]Din,
        output reg [ADDR_WIDTH-1:0] Sync_out
);
reg [ADDR_WIDTH-1:0] R1;
always @ (posedge clk or negedge rstn) begin
        if(!rstn) begin
                R1 <= 0;
                Sync_out <= 0;
        end
        else begin
                R1 <= Din;
                Sync_out <= R1;
        end
end
endmodule

module DFF #(parameter ADDR_WIDTH = 5)(
        input wire clk,
        input wire rstn,
        input wire [ADDR_WIDTH-1:0] Din,
        output reg [ADDR_WIDTH-1:0] Q
);

always @ (posedge clk or negedge rstn) begin
        if(!rstn) begin
                Q <= 'b0;
        end
        else begin
                Q <= Din;
        end
end
endmodule