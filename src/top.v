module top();

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


sync2ff start(.D(START),.rst(crypto_rstn),.clk(crypto_clk),.q(start_sync));     // Start signal sync
sync2ff mode(.D(mode),.rst(crypto_rstn),.clk(crypto_clk),.q(mode_sync));        // Mode signal sync
sync2ff zeroize(.D(ZEROIZE),.rst(crypto_rstn),.clk(crypto_clk),.q(zeroize_sync));   // Zeroize signal sync

mux_sync key(.clk(crypto_clk), .rstn(crypto_rstn), .Din(privatekey), .ena(Key_Valid), .Dout(privatekey_sync));     // Private Key sync.

async_fifo TxFIFO(.rclk(crypto_clk), 
                .ren(Tx_rd_en),        // Once aes_done rd_en = 1
                .wclk(PCLK), 
                .wen(Data_Ready),              
                .rrst(crypto_rstn), 
                .wrst(PRESETn),            
                .write_datain(plaintxt), 
                .full(Tx_full),                    
                .empty(Tx_empty),                   
                .read_dataout(Tx_RDATA)
             );

always @ (posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        Key <= 'b0;
        Mode <= 'b0;
        Data_Ready <= 'b0;
    end
    else begin
        Data_Ready <= Data_Valid;
    end
end 


// Core Instantiation
Core_top core(
    .crypto_clk(crypto_clk), 
    .crypto_rstn(crypto_rstn),
    .start(start_sync), 
    .mode(mode_sync),
    .zeroize(zeroize_sync), 
    .fifo_empty_flag(Tx_empty), 
    .private_key(privatekey_sync),
    .Data_in(Tx_RDATA),
    .Data_out(Data_out),
    .busy_flag(busy_flag), 
    .done_flag(done_flag),
    .aes_done(aes_done), 
    .key_store_done(key_store_done)
);

DFF aes_done_sync(.clk(crypto_clk), .rstn(crypto_rstn), .Din(aes_done), .Dout(Tx_rd_en));




endmodule