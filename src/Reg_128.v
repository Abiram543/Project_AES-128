module Reg_128 (
    input wire crypto_clk, crypto_rstn, zeroize,
    input wire [127:0] D_in,
    output reg [127:0] D_out
);

always @(posedge crypto_clk or negedge crypto_rstn) begin
    if (!crypto_rstn) begin
        D_out <= 'b0;
    end
    else if (zeroize)
        D_out <= 'b0;
    end
    else begin
        D_out <= D_in;
    end
end
    
endmodule