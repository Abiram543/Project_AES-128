module Key_Controller (
    input wire crypto_clk, crypto_rstn,
    input wire start, key_lock,
    output reg [3:0] Wr_Addr,
    output wire start_aes,
    output reg key_reg_sel, write_en, key_store_done, KE_sel
);
//-------------parameterization-------//
localparam IDLE     = 2'd0,
           INIT     = 2'd1,
           STORE    = 2'd2,
           DONE     = 2'd3;

//-----------State Registers----------//
reg [1:0] PS, NS;

//-----------Temp Reg & Wires----------------//
reg [3:0] roundVal;
wire count11, Round_state;

//--------------Present state logic----------------------//           
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if (!crypto_rstn) begin
        PS <= IDLE;
    end
    else begin
        PS <= NS;
    end
end

//------------Next State Logic----------//
always @(*) begin
    case (PS)
        IDLE: NS = (start && !key_lock) ? INIT : IDLE;
        INIT: NS = STORE;
        STORE: NS = count11 ? DONE : STORE;
        DONE: NS = IDLE;
        default: NS = IDLE;
    endcase
end

//------------Control signals logic---------------//
always @(*) begin
    case (PS)
        IDLE: begin
            Wr_Addr = 4'd0;
            KE_sel = 0;
            write_en = 0;
            key_reg_sel = 0;
            key_store_done = 0;
        end 
        INIT: begin
            Wr_Addr = 4'd1;
            KE_sel = 0;
            key_reg_sel = 0;    // It will select the original key value
            write_en = 0;
            key_store_done = 0;
        end
        STORE: begin
            Wr_Addr = roundVal;
            KE_sel = 1;
            key_reg_sel = 1;
            write_en = 1;
            key_store_done = 0;
        end
        DONE: begin
            key_store_done = 1;
            KE_sel = 0;
            key_reg_sel = 0;
            write_en = 0;
            Wr_Addr = 4'd0;
        end
        default: begin
            key_reg_sel = 0;
            KE_sel = 0;
            Wr_Addr = 4'd0;
            write_en = 0;
            key_store_done = 0;
        end
    endcase
end

//--------------roundVal counter-------------------//
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if (!crypto_rstn) begin
        roundVal <= 'b0;
    end
    else if (Round_state) begin
        if (count11) begin
            roundVal <= 'b0;
        end
        else begin
            roundVal <= roundVal + 1'b1;
        end
    end
    else begin
        roundVal <= 'b0;
    end
end
// Temp assignments to overcome lint errors
assign Round_state = (PS == INIT) || (PS == STORE);
assign count11 = (roundVal == 4'd11);    // roundVal 0-10

//Control signal for start the aes_core part
assign start_aes = count11 ? 1'b1 : 1'b0;

endmodule