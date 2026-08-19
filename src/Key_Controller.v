module Key_Controller (
    input wire crypto_clk, crypto_rstn,
    input wire mode,
    input wire start, next_process, written,
    output reg [3:0] Wr_Addr, Rd_Addr,
    output reg written_status, start_aes, KE_sel, read_en, write_en
);
//-------------parameterization-------//
localparam IDLE     = 2'd0,
           INIT     = 2'd1,
           ROUND    = 2'd2,
           ENDROUND = 2'd3;

//-----------State Registers----------//
reg [1:0] PS, NS;

//-----------Temp Reg & Wires----------------//
reg [3:0] roundVal;
wire count10, Round_state;

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
        IDLE : NS = start ? INIT : IDLE;
        INIT : NS = ROUND;
        ROUND: NS = count10 ? ENDROUND : ROUND;
        ENDROUND: NS = next_process ? ROUND : ENDROUND;
        default: NS = IDLE;
    endcase
end

//------------Control signals logic---------------//
always @(*) begin
    case (PS)
        IDLE: begin
            start_aes = 0;
            written_status = 0;
            KE_sel = 0;
            Wr_Addr = 4'd11;
            Rd_Addr = 4'd11;
            read_en = 0;
            write_en = 0;

        end 
        INIT: begin
            start_aes = 0;
            written_status = 0;
            KE_sel = 1;
            Wr_Addr = roundVal;
            write_en = 1;
            Rd_Addr = 4'd11;
            read_en = 0;
        end
        ROUND: begin
            written_status = 0;
            KE_sel = 0;
            if (!written) begin
                Wr_Addr = roundVal + 1;
                write_en = 1;
            end
            else begin
                Wr_Addr = 4'd11;
                write_en = 0;
            end

            if (mode || written) begin
                start_aes = 1;
                Rd_Addr = roundVal;
                read_en = 1;
            end
            else begin
                start_aes = 0;
                Rd_Addr = 4'd11;
                read_en = 0;
            end
        end
        ENDROUND: begin
            KE_sel = 0;
            start_aes = 1;
            written_status = 1;
            Wr_Addr = 0;
            write_en = 0;
            Rd_Addr = 4'd11;
            read_en = 0;
        end
        default: begin
            start_aes = 0;
            written_status = 0;
            KE_sel = 0;
            Wr_Addr = 4'd11;
            Rd_Addr = 4'd11;
            read_en = 0;
            write_en = 0;
        end
    endcase
end

//--------------roundVal counter-------------------//
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if (!crypto_rstn) begin
        roundVal <= 'b0;
    end
    else if (Round_state) begin
        if (count10) begin
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
// Temp assignments for lint error prevention
assign Round_state = (PS == ROUND);
assign count10 = (roundVal == 4'd10);    // roundVal 0-10

endmodule