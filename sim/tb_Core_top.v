`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.08.2026 19:48:13
// Design Name: 
// Module Name: tb_core_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_core_top();
reg crypto_clk, crypto_rstn;                         
reg start, mode;                                     
reg key_lock, zeroize, fifo_empty_flag;
reg [127:0] private_key;                             
reg [127:0] Data_in;                                 
wire [127:0] Data_out;                               
wire busy_flag, done_flag;                            

Core_top dut(
    .crypto_clk(crypto_clk), 
    .crypto_rstn(crypto_rstn),
    .start(start), 
    .mode(mode),
    .key_lock(key_lock), 
    .zeroize(zeroize), 
    .fifo_empty_flag(fifo_empty_flag), 
    .private_key(private_key),
    .Data_in(Data_in),
    .Data_out(Data_out),
    .busy_flag(busy_flag), 
    .done_flag(done_flag)
);

always #5 crypto_clk = ~crypto_clk;

initial begin
    crypto_clk = 0; crypto_rstn = 0;
    #7;
    crypto_rstn = 1;
    @(negedge crypto_clk);
    mode = 1; key_lock = 0; zeroize = 0; fifo_empty_flag = 0;
    start = 1;
    private_key = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
    Data_in = 128'hF69F2445DF4F9B17AD2B417BE66C3710;
    #135;
    key_lock = 1;
    #130;
    Data_in = 128'h6BC1BEE22E409F96E93D7E117393172A;
    #900;
    $finish;
end

initial begin
    $monitor(" Data_out = %h | busy_flag = %b | done_flag = %h ", Data_out, busy_flag, done_flag);
end

initial begin
    #425 mode = 0;
    Data_in = 128'h3ad77bb40d7a3660a89ecaf32466ef97;
end

initial begin
    $dumpfile("tb_core_top.vcd");
    $dumpvars(0, tb_core_top);
end
endmodule
