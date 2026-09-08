module KeyExpansion (
    input wire [127:0] key_in,
    input wire [3:0] roundVal,
    input wire mode,
    output wire [127:0] key_out
);
wire [31:0] w0, w1, w2, w3, gout;
wire [31:0] Rcon;

assign w0 = key_in[127:96];
assign w1 = key_in[95:64];
assign w2 = key_in[63:32];
assign w3 = key_in[31:0];

Rcon Rconst(.round(roundVal), .mode(mode), .Rcon(Rcon));

gbox Gbox(.word(w3), .Rcon(Rcon), .mode(mode), .gout(gout));

assign key_out[127:96] = gout ^ w0;
assign key_out[95:64]  = key_out[127:96] ^ w1;
assign key_out[63:32]  = key_out[95:64] ^ w2;
assign key_out[31:0]  = key_out[63:32] ^ w3;

endmodule