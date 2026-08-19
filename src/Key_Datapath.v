module Key_Datapath (
    input wire crypto_clk, crypto_rstn,
    input wire [127:0] Key,
    input wire mode, zeroize,
    input wire written_status, KE_sel, read_en, write_en,
    input wire [3:0] Wr_Addr, Rd_Addr,
);
    
KeyExpansion U1(.key_in(KE_in), .mode(mode), .roundVal(Wr_Addr), .key_out(KE_out));

Key_ROM U2(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .zeroize(zeroize), .write_en(write_en), 
           .read_en(read_en), .write_data(KR_in), .read_data(KR_out), .Wr_Addr(Wr_Addr), .Rd_Addr(Rd_Addr));

//------------------------Key Register for feedback---------------------------------------------//
Reg_128 K1(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .D_in(key_in), .D_out(key_reg));


assign KE_in = KE_sel ? Key : key_reg;
assign KR_in = KE_out;
assign key_in = zeroize ? 'b0 : KR_out;

//-------------------------Written status flag-----------------------------//
Reg_1   W1(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .D_in(written_in), .D_out(written));
assign written_in = zeroize ? 'b0 : (written_status ? 1'b1 : written);

endmodule