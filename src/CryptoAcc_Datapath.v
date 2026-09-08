module CryptoAcc_Datapath (
    input wire crypto_clk, crypto_rstn,
    input wire start, mode,
    input wire key_lock, zeroize, 
    input wire [127:0] private_key,
    input wire [127:0] Data_in,
    input wire [3:0] Rd_Addr,
    input wire read_en,

    output wire start_aes, key_store_done,
    output wire [127:0] Data_out
);

Key_scheduler U1(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .start(start), .mode(mode), .key_lock(key_lock), 
                 .zeroize(zeroize), .Key(private_key),  .start_aes(start_aes), .key_store_done(key_store_done), .Rd_Addr(Rd_Addr), .read_en(read_en), .Roundkey(Roundkey));

AES_core U2(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .start(start_aes), .mode(), 
            .key_in(Roundkey), .Data_in(Data_in), .done(aes_done), .Data_out(Data_out) );

endmodule