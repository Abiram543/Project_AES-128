`timescale 1ns / 1ps

module tb_AES_core();
reg crypto_clk, crypto_rstn;
reg start, mode;
reg [127:0] key_in, Data_in;
wire [127:0] Data_out;
wire done;

AES_core dut(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .start(start), .mode(mode), .key_in(key_in), .Data_in(Data_in), .Data_out(Data_out), .done(done));

always #5 crypto_clk = ~crypto_clk;

initial begin
    crypto_clk = 0; crypto_rstn = 0;
    #7;
    crypto_rstn = 1;
    
    @(negedge crypto_clk);
    start = 1; mode = 1;
    key_in = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
    Data_in = 128'h6BC1BEE22E409F96E93D7E117393172A;
    
    @(negedge crypto_clk);
    @(negedge crypto_clk);
    @(negedge crypto_clk);
    key_in = 128'ha0fafe1788542cb123a339392a6c7605;
    @(negedge crypto_clk);
    key_in = 128'hf2c295f27a96b9435935807a7359f67f;
    @(negedge crypto_clk);
    key_in = 128'h3d80477d4716fe3e1e237e446d7a883b;
    @(negedge crypto_clk);
    key_in = 128'hef44a541a8525b7fb671253bdb0bad00;
    @(negedge crypto_clk);
    key_in = 128'hd4d1c6f87c839d87caf2b8bc11f915bc;
    @(negedge crypto_clk);
    key_in = 128'h6d88a37a110b3efddbf98641ca0093fd;
    @(negedge crypto_clk);
    key_in = 128'h4e54f70e5f5fc9f384a64fb24ea6dc4f;
    @(negedge crypto_clk);
    key_in = 128'head27321b58dbad2312bf5607f8d292f;
    @(negedge crypto_clk);
    key_in = 128'hac7766f319fadc2128d12941575c006e;
    @(negedge crypto_clk);
    key_in = 128'hd014f9a8c9ee2589e13f0cc8b6630ca6;
    @(negedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk);
    @(posedge crypto_clk); 
    $finish;  
end

initial begin
    $monitor(" ciphertxt = %h, done = %b\n", Data_out, done);
    $monitor("time = %t | AddRoundKey=%h | SubBytes=%h | ShiftRows=%h | MixCol=%h | state_reg = %h\n", $time, dut.AES_Dtp.U1.Q, dut.AES_Dtp.U2.Q, dut.AES_Dtp.U3.Q, dut.AES_Dtp.U4.Q, dut.AES_Dtp.O1.D_out);
end

endmodule
