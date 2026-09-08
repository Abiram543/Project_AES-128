module Core_top (
    input wire crypto_clk, crypto_rstn,
    input wire start, mode,
    input wire key_lock, zeroize, next_process, fifo_empty_flag, 
    input wire [127:0] private_key,
    input wire [127:0] Data_in,
    output wire [127:0] Data_out,
    output wire busy_flag, done_flag
);

wire [3:0] Rd_Addr;
wire read_en, start_aes, key_store_done;


CryptoAcc_Controller U1(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .start(start), .mode(mode), .start_aes(start_aes), 
                        .next_process(next_process), .key_lock(key_lock), .zeroize(zeroize),
                        .fifo_empty_flag(fifo_empty_flag), .Rd_Addr(Rd_Addr), .read_en(read_en), .busy_flag(busy_flag), .done_flag(done_flag));

CryptoAcc_Datapath U2(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .start(start), .mode(mode), .key_lock(key_lock),
                        .zeroize(zeroize), .private_key(private_key), .Data_in(Data_in), .Rd_Addr(Rd_Addr), .read_en(read_en), 
                         .start_aes(start_aes), .key_store_done(key_store_done), .Data_out(Data_out));
    
endmodule