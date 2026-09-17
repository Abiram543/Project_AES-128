module Key_ROM (
    input wire crypto_clk, crypto_rstn,
    input wire zeroize,
    input wire write_en, read_en,
    input wire [127:0] write_data,
    input wire [3:0] Wr_Addr, Rd_Addr,
    output reg [127:0] read_data
);
/*Key Register for 11 round keys*/
reg [127:0] Key_MEM [0:11];


//Write Logic//
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if(!crypto_rstn) begin
        Key_MEM[0]  <= 'b0;
        Key_MEM[1]  <= 'b0;
        Key_MEM[2]  <= 'b0;
        Key_MEM[3]  <= 'b0;
        Key_MEM[4]  <= 'b0;
        Key_MEM[5]  <= 'b0;
        Key_MEM[6]  <= 'b0;
        Key_MEM[7]  <= 'b0;
        Key_MEM[8]  <= 'b0;
        Key_MEM[9]  <= 'b0;
        Key_MEM[10] <= 'b0;
        Key_MEM[11] <= 'b0;
    end
    else if(zeroize) begin
        Key_MEM[0]  <= 'b0;
        Key_MEM[1]  <= 'b0;
        Key_MEM[2]  <= 'b0;
        Key_MEM[3]  <= 'b0;
        Key_MEM[4]  <= 'b0;
        Key_MEM[5]  <= 'b0;
        Key_MEM[6]  <= 'b0;
        Key_MEM[7]  <= 'b0;
        Key_MEM[8]  <= 'b0;
        Key_MEM[9]  <= 'b0;
        Key_MEM[10] <= 'b0;
        Key_MEM[11] <= 'b0;
    end
    else if(write_en) begin
        Key_MEM[Wr_Addr] <= write_data;
    end
    else begin
        Key_MEM[Wr_Addr] <= Key_MEM[Wr_Addr];
    end
end
//Read Logic//
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if(!crypto_rstn) begin
        read_data <= 'b0;
    end
    else if(zeroize) begin
        read_data <= 'b0;
    end
    else if (read_en) begin
        read_data <= Key_MEM[Rd_Addr];
    end
    else begin
        read_data <= read_data;
    end
end


endmodule