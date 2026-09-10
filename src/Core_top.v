module Core_top (
    input wire crypto_clk, crypto_rstn,
    input wire start, mode,
    input wire key_lock, zeroize, fifo_empty_flag, 
    input wire [127:0] private_key,
    input wire [127:0] Data_in,
    output wire [127:0] Data_out,
    output wire busy_flag, done_flag, aes_done
);

wire start_aes, key_store_done, key_written;


CryptoAcc_Controller Cryp_Ctrl (.crypto_clk(crypto_clk), 
                                .crypto_rstn(crypto_rstn), 
                                .start(start), 
                                .start_aes(start_aes),
                                .aes_done(aes_done),
                                .fifo_empty_flag(fifo_empty_flag),  
                                .busy_flag(busy_flag), 
                                .done_flag(done_flag),
                                .key_written(key_written),
                                .key_store_done(key_store_done)
                        );

CryptoAcc_Datapath Cryp_Dpt (.crypto_clk(crypto_clk), 
                             .crypto_rstn(crypto_rstn), 
                             .start(start), 
                             .mode(mode), 
                             .key_lock(key_lock),
                             .zeroize(zeroize), 
                             .private_key(private_key), 
                             .Data_in(Data_in), 
                             .aes_done(aes_done), 
                             .start_aes(start_aes), 
                             .key_store_done(key_store_done), 
                             .Data_out(Data_out),
                             .key_written(key_written)
                      );
    
endmodule