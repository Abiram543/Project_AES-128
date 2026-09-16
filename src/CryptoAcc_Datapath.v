module CryptoAcc_Datapath (
    input wire crypto_clk, crypto_rstn,
    input wire start, mode, start_aes, // from controller
    input wire zeroize, 
    input wire [127:0] private_key,
    input wire [127:0] Data_in,
    output wire aes_done,
    output wire key_store_done, key_written,
    output wire [127:0] Data_out
);

wire [127:0] Roundkey;
wire [3:0] Rd_Addr;
wire read_en;


Key_scheduler U1(.crypto_clk(crypto_clk), 
                 .crypto_rstn(crypto_rstn), 
                 .start(start), 
                 .mode(mode),  
                 .zeroize(zeroize), 
                 .Key(private_key),  
                 .key_store_done(key_store_done), 
                 .key_written(key_written), 
                 .Rd_Addr(Rd_Addr), 
                 .read_en(read_en), 
                 .Roundkey(Roundkey)
                 );

AES_core U2(.crypto_clk(crypto_clk), 
            .crypto_rstn(crypto_rstn), 
            .start(start_aes), 
            .mode(mode), 
            .zeroize(zeroize), 
            .key_in(Roundkey), 
            .Data_in(Data_in), 
            .aes_done(aes_done), 
            .Data_out(Data_out) ,
            .Rd_Addr(Rd_Addr), .read_en(read_en)
            );

endmodule