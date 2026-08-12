module Rcon (
    input wire [3:0] round,
    input wire mode,
    output wire [31:0] Rcon
);
always @(*) begin
    if (mode) begin
        case (round)
        4'd1: Rcon = 32'h01000000;
        4'd2: Rcon = 32'h02000000;
        4'd3: Rcon = 32'h04000000;
        4'd4: Rcon = 32'h08000000;
        4'd5: Rcon = 32'h10000000;
        4'd6: Rcon = 32'h20000000;
        4'd7: Rcon = 32'h40000000;
        4'd8: Rcon = 32'h80000000;
        4'd9: Rcon = 32'h1b000000;
        4'd10: Rcon = 32'h36000000;
        default: Rcon = 32'h00000000;
        endcase
    end
    else begin
        case (round)
        4'd10: Rcon = 32'h01000000;
        4'd9: Rcon = 32'h02000000;
        4'd8: Rcon = 32'h04000000;
        4'd7: Rcon = 32'h08000000;
        4'd6: Rcon = 32'h10000000;
        4'd5: Rcon = 32'h20000000;
        4'd4: Rcon = 32'h40000000;
        4'd3: Rcon = 32'h80000000;
        4'd2: Rcon = 32'h1b000000;
        4'd1: Rcon = 32'h36000000;
        default: Rcon = 32'h00000000;
        endcase
    end
end
    
endmodule