module top (
//Inputs from APB Master
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire [7:0]  PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PWDATA,
    input  wire [3:0]  PSTRB,
    input  wire [2:0]  PPROT,
// For Core inputs 
    input wire         crypto_clk,
    input wire         crypto_rstn,
//Outputs to APB Master
    output wire        PSLVERR,
    output wire        SEC_VIOLATION,
    output wire [31:0] PRDATA,
    output wire        PREADY
);

APB_Interface APB_Itf(.PCLK(PCLK),
                       .PRESETn(PRESETn),
                       .PADDR(PADDR),
                       .PSEL(PSEL),
                       .PENABLE(PENABLE),
                       .PWRITE(PWRITE),
                       .PWDATA(PWDATA),
                       .PSTRB(PSTRB),
                       .PPROT(PPROT),
                       .done_flag_sync(core_done_flag), 
                       .busy_flag_sync(core_busy_flag),
                       .RxData_out(Rx_Data_out),
                       .PRDATA(PRDATA),
                       .PREADY(PREADY),
                       .PSLVERR(PSLVERR),
                       .SEC_VIOLATION(SEC_VIOLATION),
                       .KEY(KEY),
                       .DATA(plaintxt),
                       .START(START), 
                       .MODE(MODE),
                       .KEYLOCK(KEYLOCK),
                       .ZEROIZE(ZEROIZE),
                       .DATA_WRITE_DONE(DATA_WRITE_DONE),
                       .DONE(DONE)
                    );

// Secure Register for KEY and MODE
Secure_Reg SR(.PCLK(PCLK),
              .PRESETn(PRESETn),
              .KEYLOCK(KEYLOCK),
              .MODE(MODE),
              .KEY(KEY),
              .mode(mode),
              .keylock(keylock),
              .private_key(private_key)
            );

// Tx FIFO 
wire Tx_rd_en, Tx_wr_en;
assign Tx_rd_en = aes_done || key_store_done; 
assign Tx_wr_en = DATA_WRITE_DONE;                   

fifo_top TxFIFO(.rclk(crypto_clk), 
                .rd_en(Tx_rd_en), 
                .wclk(PCLK), 
                .wr_en(Tx_wr_en),              
                .rdrstn(crypto_rstn), 
                .wrstn(PRESETn),            
                .Data_in(plaintxt), 
                .full(Tx_full),                    
                .empty(Tx_empty),                   
                .Data_out(Tx_Data_out)
             );

//CDC for Key and Control signals

//Core Instantiation
Core_top core(
    .crypto_clk(crypto_clk), 
    .crypto_rstn(crypto_rstn),
    .start(START), 
    .mode(mode),
    .key_lock(keylock), 
    .zeroize(ZEROIZE), 
    .fifo_empty_flag(Tx_empty), 
    .private_key(private_key),
    .Data_in(Tx_Data_out),
    .Data_out(Core_Data_out),
    .busy_flag(core_busy_flag), 
    .done_flag(core_done_flag),
    .aes_done(aes_done), 
    .key_store_done(key_store_done)
);

wire Rx_wr_en, Rx_rd_en;
assign Rx_wr_en = core_done_flag;
assign Rx_rd_en = DONE;

//Rx FIFO
fifo_top RxFIFO(.rclk(PCLK), 
                .rd_en(Rx_rd_en), 
                .wclk(crypto_clk), 
                .wr_en(Rx_wr_en),              
                .rdrstn(PRESETn), 
                .wrstn(crypto_rstn),            
                .Data_in(Core_Data_out), 
                .full(Rx_full),                    
                .empty(Rx_empty),                   
                .Data_out(Rx_Data_out)
             );

// Synchronizers for STATUS Signals

    
endmodule