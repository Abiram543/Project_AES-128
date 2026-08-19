module Key_ROM (
    input wire crypto_clk, crypto_rstn,
    input wire zeroize,
    input wire write_en, read_en,
    input wire [127:0] write_data,
    input wire [3:0] Wr_Addr, Rd_Addr,
    output reg [127:0] read_data
);
//----------------ROM----------------//
reg [127:0] Key_ROM [0:11];

//-----------------Temporory Vars-------------------//
wire addrVal;
integer i;

//------------------Write Logic-------------------------//
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if(!crypto_rstn || zeroize) begin
        for (i = 0; i < 12; i = i + 1) begin
            Key_ROM[i] <= 'b0;
        end
    end
    else if(write_en) begin
        Key_ROM[Wr_Addr] <= write_data;
    end
    else begin
        Key_ROM[Wr_Addr] <= Key_ROM[Wr_Addr];
    end
end
//------------------Read Logic-------------------------//
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if(!crypto_rstn || zeroize) begin
        read_data <= 'b0;
    end
    else if (read_en) begin
        read_data <= Key_ROM[Rd_Addr];
    end
    else begin
        read_data <= read_data;
    end
end


endmodule