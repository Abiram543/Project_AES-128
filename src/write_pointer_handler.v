
module write_pointer_handler #(parameter ADDR_WIDTH = 5) (wclk, wen, wrst, g_wptr, b_wptr, g_rptr, full);
input wclk, wen, wrst;
input [ADDR_WIDTH:0] g_rptr;
output reg [ADDR_WIDTH:0] g_wptr, b_wptr;
reg [ADDR_WIDTH:0] sync1, g_rptr_sync;
output wire full;
reg [ADDR_WIDTH:0] b_rptr;

always@(posedge wclk or negedge wrst)begin
        if(!wrst) b_wptr <= 0;
        else if(wen & !full) b_wptr <= b_wptr + 1;
end

wire [ADDR_WIDTH:0] g_wptr_temp;
assign g_wptr_temp = b_wptr ^ (b_wptr >> 1);

always@(posedge wclk or negedge wrst)begin
        if(!wrst) g_wptr <= 0;
        else g_wptr <= g_wptr_temp;
end

//Dual rank synchronizer for gray coded read pointer from rclk domain
always@(posedge wclk or negedge wrst)begin
        if(!wrst) sync1 <= 0;
        else sync1 <= g_rptr;
end
always@(posedge wclk or negedge wrst)begin
        if(!wrst) g_rptr_sync <= 0;
        else g_rptr_sync <= sync1;
end

//Conversion of synchronized gray coded read pointer to binary coded
//(same generate-loop rationale as read_pointer_handler above)
integer i;
always@(*)begin
        b_rptr[ADDR_WIDTH] = g_rptr_sync[ADDR_WIDTH];
        for(i = ADDR_WIDTH-1; i >= 0; i = i - 1)
                b_rptr[i] = b_rptr[i+1] ^ g_rptr_sync[i];
end

assign full = (b_rptr[ADDR_WIDTH] != b_wptr[ADDR_WIDTH]) & (b_wptr[ADDR_WIDTH-1:0] == b_rptr[ADDR_WIDTH-1:0]);
endmodule