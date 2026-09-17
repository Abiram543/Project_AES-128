`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.09.2026 15:07:43
// Design Name: 
// Module Name: demo2_top
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


module demo2_top(
    input  wire        PCLK,
    input  wire        PRESETn,
    input wire crypto_clk,
    input wire crypto_rstn,
    input wire start,
    input  wire [7:0]  PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input wire mode,
    input wire zeroize, fifo_empty_flag,
    input wire [127:0] private_key, Data_in,
    output wire [127:0] Data_out,
    output wire busy_flag, done_flag, aes_done, key_store_done, Rx_empty,
    
    output wire [127:0] Rx_Data_out,
    output reg [31:0] PRDATA    
);

wire Rx_rd_en;

Core_top U1(
    .crypto_clk(crypto_clk), 
    .crypto_rstn(crypto_rstn),
    .start(start), 
    .mode(mode),
    .zeroize(zeroize), 
    .fifo_empty_flag(fifo_empty_flag), 
    .private_key(private_key),
    .Data_in(Data_in),
    .Data_out(Data_out),
    .busy_flag(busy_flag), 
    .done_flag(done_flag),
    .aes_done(aes_done), 
    .key_store_done(key_store_done)
);

reg Rx_wr_en;
always @ (posedge crypto_clk or negedge crypto_rstn) begin
    if(!crypto_rstn) begin
        Rx_wr_en <= 'b0;
    end
    else begin
        Rx_wr_en <= aes_done;
    end
end

//Rx FIFO
fifo_top RxFIFO(.rclk(PCLK), 
                .rd_en(Rx_rd_en), 
                .wclk(crypto_clk), 
                .wr_en(Rx_wr_en),              
                .rdrstn(PRESETn), 
                .wrstn(crypto_rstn),            
                .Data_in(Data_out), 
                .full(Rx_full),                    
                .empty(Rx_empty),                   
                .Data_out(Rx_Data_out)
             );

reg Rx_empty_delay;
// Rx_Empty delay for capturing Output
always @ (posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        Rx_empty_delay <= 'b0;
    end
    else begin
        Rx_empty_delay <= Rx_empty;
    end
end


reg [2:0] count;
// Rx Read ena logic
always @ (posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        count <= 'b0;
    end
    else begin
        if(!Rx_empty_delay && done_flag_sync && !PWRITE)begin
            if(count == 3'd4)
                count <= 'b0;
            else
                count <= count + 1;
        end
        else count <= 'b0;
    end
end

assign Rx_rd_en = (count == 3'd1);

reg [127:0] Ciphertxt;
always @ (posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        Ciphertxt <= 'b0;
    end
    else if (Rx_rd_en) begin
        Ciphertxt <= Rx_Data_out;
    end
end 

wire apb_read;
assign apb_read  = PSEL && PENABLE && !PWRITE;

always @ (posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        PRDATA <= 'b0;
    end
    else begin
        if(apb_read) begin
            case(PADDR)
            8'h38: PRDATA <= Ciphertxt[127:96];
            8'h3c: PRDATA <= Ciphertxt[95:64];
            8'h40: PRDATA <= Ciphertxt[63:32];
            8'h44: PRDATA <= Ciphertxt[31:0];
            default: PRDATA <= 'b0;
            endcase
        end
    end
end
endmodule
