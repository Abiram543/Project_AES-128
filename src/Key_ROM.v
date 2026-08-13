module Key_ROM (
    input wire crypto_clk, crypto_rstn,
    input wire write_en, read_en,
    input wire [127:0] write_data,
    input wire [3:0] Address,
    output reg [127:0] read_data
);
//----------------ROM----------------//
reg [127:0] Key_ROM [0:10];

//-----------------Temporory Vars-------------------//
wire addrVal;
integer i;

//----------------------Logic-------------------------//
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if(!crypto_rstn) begin
        for (i = 0; i < 10; i = i + 1) begin
            Key_ROM[i] <= 'b0;
        end
        read_data <= 'b0;
    end
    else if(write_en) begin
        Key_ROM[Address] <= write_data;
    end
    else if (read_en) begin
        read_data <= Key_ROM[Address];
    end
    else begin
        read_data <= 'b1;
        Key_ROM[Address] <= Key_ROM[Address];
    end
end


endmodule