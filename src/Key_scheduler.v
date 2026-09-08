module Key_scheduler (
    input wire crypto_clk, crypto_rstn,
    input wire mode, 
    input wire start, key_lock, zeroize,
    input wire [127:0] Key,     // Original private key
    input wire [3:0] Rd_Addr,
    input wire read_en,
    output wire [127:0] Roundkey,    // Round keys for each rounds 0-10
    output wire start_aes, key_store_done
);

wire key_reg_sel, KE_sel, write_en;
wire [3:0] Wr_Addr;


Key_Controller U1(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .start(start), .key_lock(key_lock), 
                  .KE_sel(KE_sel), .Wr_Addr(Wr_Addr), .start_aes(start_aes), .key_reg_sel(key_reg_sel), .write_en(write_en), .key_store_done(key_store_done));

Key_Datapath U2(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .mode(mode), .key_reg_sel(key_reg_sel), .key_lock(key_lock),
                .KE_sel(KE_sel), .write_en(write_en), .read_en(read_en), .Wr_Addr(Wr_Addr), .Rd_Addr(Rd_Addr), .Read_data(Roundkey), .zeroize(zeroize), .Key(Key));
endmodule