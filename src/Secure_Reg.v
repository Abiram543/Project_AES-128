module Secure_Reg (
    input wire PCLK,
    input wire PRESETn,
    input wire KEYLOCK,
    input wire MODE,
    input wire [127:0] KEY,

    output reg mode,
    output reg keylock,
    output reg [127:0] private_key
);



always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        mode <= 'b0;
        private_key <= 'b0;
    end
    else if (!KEYLOCK && !keylock) begin
        mode <= MODE;
        private_key <= KEY;
    end
end

always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        keylock <= 'b0;
    end
    else if (KEYLOCK) begin
        keylock <= 1;
    end
end
    
endmodule