module read_pointer_handler #(parameter ADDR_WIDTH = 5) (rclk, ren, rrst, g_rptr, b_rptr, g_wptr, empty);
input rclk, ren, rrst;
input [ADDR_WIDTH:0] g_wptr;
output reg [ADDR_WIDTH:0] b_rptr, g_rptr;
output empty;
reg [ADDR_WIDTH:0] g_wptr_sync, sync1;

//Dual rank synchronizer
always@(posedge rclk or negedge rrst)begin
        if(!rrst) sync1 <= 0;
        else sync1 <= g_wptr;
end
always@(posedge rclk or negedge rrst)begin
        if(!rrst) g_wptr_sync <= 0;
        else g_wptr_sync <= sync1;
end

//Read pointer management
always@(posedge rclk or negedge rrst)begin
        if(~rrst) b_rptr <= 0;
        else if (ren & !empty) b_rptr <= b_rptr + 1;
end

wire [ADDR_WIDTH:0] g_rptr_temp;
//Conversion of binary to gray coded read pointer for domain crossing to write
//pointer handler
assign g_rptr_temp = b_rptr ^ (b_rptr >> 1);

//Latching gray coded read pointer for domain crossing because directly
//transmitting combo block output to different domain can cause glitch
always@(posedge rclk or negedge rrst)begin
        if(!rrst) g_rptr <= 0;
        else g_rptr <= g_rptr_temp;
end

reg [ADDR_WIDTH:0] b_wptr;
//Convert synchronized gray coded write pointer to binary coded.
//Was a manually unrolled XOR chain at fixed width -- switched to a
//generate loop here since this module is now parameterized across two
//different widths (TX=9b, RX=6b) from the same source. Functionally
//identical to the manual chain: b_wptr[MSB] = g_wptr_sync[MSB], then
//each lower bit XORs the previous binary bit with the corresponding gray bit.
integer i;
always@(*)begin
        b_wptr[ADDR_WIDTH] = g_wptr_sync[ADDR_WIDTH];
        for(i = ADDR_WIDTH-1; i >= 0; i = i - 1)
                b_wptr[i] = b_wptr[i+1] ^ g_wptr_sync[i];
end

//Driving empty signal
assign empty = (b_wptr[ADDR_WIDTH] == b_rptr[ADDR_WIDTH]) & (b_wptr[ADDR_WIDTH-1:0] == b_rptr[ADDR_WIDTH-1:0]);
endmodule
