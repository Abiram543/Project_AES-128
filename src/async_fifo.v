module async_fifo #(parameter ADDR_WIDTH = 5) (wclk, wen, wrst, write_datain, rclk, ren, rrst, read_dataout, empty, full);
input wclk, wen, wrst, rclk, ren, rrst;
output wire empty;
output wire full;
input [7:0] write_datain;
output reg [7:0] read_dataout;
integer i;
reg [7:0] fifo_register [(1<<ADDR_WIDTH)-1:0];
wire [ADDR_WIDTH:0] b_wptr, g_wptr, b_rptr, g_rptr;

write_pointer_handler #(.ADDR_WIDTH(ADDR_WIDTH)) w1(wclk, wen, wrst, g_wptr, b_wptr, g_rptr, full);
read_pointer_handler  #(.ADDR_WIDTH(ADDR_WIDTH)) w2(rclk, ren, rrst, g_rptr, b_rptr, g_wptr, empty);

always@(posedge wclk)begin
        if(wen & !full) fifo_register[b_wptr[ADDR_WIDTH-1:0]] <= write_datain;
end
always@(posedge rclk or negedge rrst)begin
        if(!rrst) read_dataout <= 0;
        else if(ren & !empty) read_dataout <= fifo_register[b_rptr[ADDR_WIDTH-1:0]];
end
endmodule

