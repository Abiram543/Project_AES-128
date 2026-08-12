module AddRoundKey (
    input wire [127:0] A,
    input wire [127:0] key,
    output wire [127:0] Q
);

// XOR with the round key which is generates from key expansion block
assign Q = A ^ key;

endmodule