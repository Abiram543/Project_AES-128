module gbox (
    input wire [31:0] word, Rcon,
    input wire mode,
    output wire [31:0] gout
);

wire [31:0] temp, sout;

assign temp = {word[23:16], word[15:8], word[7:0], word[31:24]};    // Rotate word

sbox_comb U1(.A(temp[31:24]), .encrypt(mode), .Q(sout[31:24]));
sbox_comb U2(.A(temp[23:16]), .encrypt(mode), .Q(sout[23:16]));
sbox_comb U3(.A(temp[15:8]), .encrypt(mode), .Q(sout[15:8]));
sbox_comb U4(.A(temp[7:0]), .encrypt(mode), .Q(sout[7:0]));

assign gout = sout ^ Rcon;

endmodule

