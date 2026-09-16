module DFF(Din,rstn,clk,Dout);
input Din,rstn,clk;
output reg Dout;

always@(posedge clk or negedge rstn)begin
    if(!rstn)begin
        Dout <= 'b0;
    end
    else Dout <= Din;
end

endmodule