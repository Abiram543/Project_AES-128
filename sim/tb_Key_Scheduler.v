`timescale 1ns / 1ps

module tb_Key_Scheduler();
reg crypto_clk, crypto_rstn;
reg mode;
reg start, key_lock, zeroize;
reg [127:0] Key;     // Original private key
reg [3:0] Rd_Addr;
reg read_en;
wire [127:0] Roundkey;
wire start_aes, key_store_done;

Key_scheduler dut(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .mode(mode), 
                  .start(start), .key_lock(key_lock), .zeroize(zeroize), .Rd_Addr(Rd_Addr), 
                  .Key(Key), .read_en(read_en), .Roundkey(Roundkey), .start_aes(start_aes), .key_store_done(key_store_done));

always #5 crypto_clk = ~crypto_clk;

initial begin
    crypto_clk = 0; crypto_rstn = 0;
    #7;
    crypto_rstn = 1;
    @(negedge crypto_clk);
    start = 1; mode = 1; key_lock = 0; zeroize = 0;
    Key = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    Rd_Addr = 4'd0;
    read_en = 1;
    @(posedge crypto_clk);
    Rd_Addr = 4'd1;
    read_en = 1;
    @(posedge crypto_clk);
    Rd_Addr = 4'd2;
    read_en = 1;
    @(posedge crypto_clk);
    Rd_Addr = 4'd3;
    read_en = 1;
    #5 $finish;
end
initial begin
    $monitor(" RoundKey = %h | AES_Start = %h | Done = %h | Key_reg = %h", Roundkey, start_aes, key_store_done, dut.U2.K1.D_out);
end
endmodule
