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
