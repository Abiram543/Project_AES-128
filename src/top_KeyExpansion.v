module top_KeyExpansion (
    input wire crypto_clk, crypto_rstn, 
    input wire [127:0] key_in,
    input wire [3:0] roundVal,
    input wire mode, write_en, read_en,
    output wire [127:0] key_out
);
wire [127:0] w1, w2, w3;
KeyExpansion U1(.key_in(key_in), .roundVal(roundVal), .mode(mode), .key_out(w1));
Key_ROM U2(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .write_en(write_en), .read_en(read_en), .write_data(w2), .Address(roundVal), .read_data(w3));

//--------Round 0 --> Original Key------------//
assign w2 = (roundVal == 0) ? key_in : w1;

//-------Output selection based on mode-------//
assign key_out = mode ? w1 : w3;

endmodule