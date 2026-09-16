`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.09.2026 01:28:12
// Design Name: 
// Module Name: demo_top
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


module demo_top(
    input  wire        PCLK,
    input  wire        PRESETn,

    input  wire [7:0]  PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PWDATA,
    input  wire [2:0]  PPROT,
    
    input wire crypto_clk,
    input wire crypto_rstn,
    input wire rd_en,
    
    output wire [127:0] RDATA,
    output wire Tx_empty, Tx_full,
    output reg [127:0] Key,
    output reg Mode
    );
    wire [127:0] privatekey, plaintxt;
    wire Key_Valid, Data_Valid, mode_Valid, mode;
    reg Data_Ready;
    wire ZEROIZE;
    
    APB_Input_Interface dut1(
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PADDR(PADDR),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .PPROT(PPROT),
    . privatekey(privatekey),
    . Key_Valid(Key_Valid),
    . plaintxt(plaintxt),
    . Data_Valid(Data_Valid),
    . mode(mode),
    . mode_Valid(mode_Valid),
    . KEYLOCK(KEYLOCK),
    . ZEROIZE(ZEROIZE),
    . START(START)
);


fifo_top TxFIFO(.rclk(crypto_clk), 
                .rd_en(rd_en), 
                .wclk(PCLK), 
                .wr_en(Data_Ready),              
                .rdrstn(crypto_rstn), 
                .wrstn(PRESETn),            
                .Data_in(plaintxt), 
                .full(Tx_full),                    
                .empty(Tx_empty),                   
                .Data_out(RDATA)
             );

always @ (posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        Key <= 'b0;
        Mode <= 'b0;
        Data_Ready <= 'b0;
    end
    else if (ZEROIZE) begin
        Key <= 'b0;
        Mode <= 'b0;
        Data_Ready <= 'b0;
    end
    else begin
        Data_Ready <= Data_Valid;
        if(Key_Valid) begin
            Key <= privatekey;
        end
        if(mode_Valid) begin
            Mode <= mode;
        end
    end
end 
endmodule
