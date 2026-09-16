module mux_sync(
    input wire clk, rstn,
    input wire ena,
    input wire [127:0] Din,
    output wire [127:0] Dout
);

sync2ff start(.D(ena),.rst(rstn),.clk(clk),.q(ena_sync));

always @ (posedge clk or negedge rstn) begin
    if(!rstn)
        Dout <= 'b0;
    else if (ena_sync)
        Dout <= Din;
end

endmodule