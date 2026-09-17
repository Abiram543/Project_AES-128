module AES_Controller_v2 (
    input wire crypto_clk, crypto_rstn,
    input wire start,            // Start the AES process
    input wire mode,            // mode = 1 --> Encryption, mode = 0 --> Decryption
    input wire zeroize,
//Generating Control Signals//    
    output reg [2:0] ARK_sel, IARK_sel,
    output reg [1:0] SB_sel, state_sel,
    output reg SR_sel, ISR_sel, MC_sel, IMC_sel, Data_sel, out_sel, ARK_key_sel, IARK_key_sel,
//status signal//    
    output reg done,
    output reg [3:0] Rd_Addr,
    output reg read_en
);

localparam IDLE = 3'd0, 
           INIT = 3'd1,
           R0   = 3'd2,
           R1_9 = 3'd3,
           R10  = 3'd4,
           FINAL = 3'd5;

//State Registers//
reg [2:0] PS, NS;

//Temporory Vars//
wire temp1, temp2, temp3;
reg [3:0] count;
wire count11;

//Present state Logic//
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if (!crypto_rstn) begin
        PS <= IDLE;
    end
    else if (zeroize) begin
        PS <= IDLE;
    end
    else begin
        PS <= NS;
    end
end

//Next State Logic//
always @(*) begin
    case (PS)
        IDLE: NS = start ? INIT : IDLE;
        INIT: NS = R0;
        R0  : NS = R1_9;
        R1_9: NS = temp2 ? R10 : R1_9;
        R10 : NS = FINAL;
        FINAL:NS = IDLE; 
        default: NS = IDLE;
    endcase
end

//Round Value counter logic//
reg [3:0] roundVal;
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if (!crypto_rstn) begin
        roundVal <= 'b0;
    end
    else if (temp1) begin
        if (temp2) begin
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

assign temp1 = (PS == R1_9);
assign temp2 = (roundVal == 4'd8);

//Output control signals logic//
always @(*) begin
    case (PS)
        IDLE: begin
            ARK_sel = 'b0;
            IARK_sel = 'b0;
            SB_sel  = 'b0;
            SR_sel  = 0;
            ISR_sel = 0;
            MC_sel  = 0;
            IMC_sel = 0;
            Data_sel = 0;
            state_sel = 'b0;
            out_sel = 0;
            ARK_key_sel = 'b0;
            IARK_key_sel = 'b0;
            done = 0;
            Rd_Addr = 0;
            read_en = 0;
        end 
        INIT: begin
            ARK_sel = 'b0;
            IARK_sel = 'b0;
            SB_sel  = 'b0;
            SR_sel  = 0;
            ISR_sel = 0;
            MC_sel  = 0;
            IMC_sel = 0;
            Data_sel = 1;
            state_sel = 'b0;
            out_sel = 0;
            ARK_key_sel = 0;
            IARK_key_sel = 0;
            Rd_Addr = mode ? 0 : 4'd10;
            read_en = 1;
            done = 0;
        end
        R0: begin
            Data_sel = 0;
            done = 0;
            out_sel = 0;
            Rd_Addr = mode ? count : (4'd10 - count);
            read_en = 1;
            // if (mode) begin
            //     ARK_sel = 2'd1;    // Selecting only AddRoundKey for Initial transformation
            //     IARK_sel = 'b0;
            //     SB_sel  = 'b0;
            //     SR_sel  = 0;
            //     ISR_sel = 0;
            //     MC_sel  = 0;
            //     IMC_sel = 0;
            //     state_sel = 2'b01;
            // end
            // else begin
            //     IARK_sel = 2'd1;    // 3 transformation ARK, InvSubBytes, InvShiftRows
            //     ARK_sel = 'b0;
            //     SB_sel  = 2'b10;
            //     SR_sel  = 0;
            //     ISR_sel = 1;
            //     MC_sel  = 0;
            //     IMC_sel = 0;
            //     state_sel = 2'b10;
            // end
            ARK_sel = mode ? 2'd1 : 'b0;
            IARK_sel = !mode ? 2'd1 : 'b0;
            ARK_key_sel = mode ? 1'b1 : 'b0;
            IARK_key_sel = !mode ? 1'b1 : 'b0;
            SB_sel = !mode ? 2'd2 : 'b0;
            SR_sel = 0;
            ISR_sel = !mode ? 1'b1 : 'b0;
            MC_sel = 0;
            IMC_sel = 0;
            state_sel = mode ? 2'd1 : 2'd2;
        end
        R1_9: begin
            Data_sel = 0;
            done = 0;
            out_sel = 0;
            ARK_key_sel = mode ? 1'b1 : 'b0;
            IARK_key_sel = !mode ? 1'b1 : 'b0;
            ARK_sel = mode ? 2'd2 : 'b0;
            IARK_sel = !mode ? 2'd2 : 'b0;
            SB_sel = mode ? 2'd1 : 2'd3;
            SR_sel = mode ? 1 : 0;
            ISR_sel = !mode ? 1'b1 : 'b0;
            MC_sel = mode ? 1 : 0;
            IMC_sel = !mode ? 1 : 0;
            state_sel = mode ? 2'd1 : 2'd2;
            Rd_Addr = mode ? count : (4'd10 - count);
            read_en = 1;
            // if (mode) begin         // Encryption mode
            //     ARK_sel = 3'b010;
            //     SB_sel  = 2'b01;
            //     SR_sel  = 1;
            //     ISR_sel = 0;
            //     MC_sel  = 1;
            //     IMC_sel = 0;
            //     state_sel = 2'b01;
            // end
            // else begin
            //     ARK_sel = 3'b100;
            //     SB_sel  = 2'b11;
            //     SR_sel  = 0;
            //     ISR_sel = 1;
            //     MC_sel  = 0;
            //     IMC_sel = 1;
            //     state_sel = 2'b10;
            // end
        end
        R10: begin
            Data_sel = 0;
            done = 0;
            out_sel = 0;
            ARK_key_sel = mode ? 1'b1 : 'b0;
            IARK_key_sel = !mode ? 1'b1 : 'b0;
            ARK_sel = mode ? 2'd3 : 'b0;
            IARK_sel = !mode ? 2'd2 : 'b0;
            SB_sel = mode ? 2'd1 : 2'd0;
            SR_sel = mode ? 1 : 0;
            ISR_sel = 0;
            MC_sel = 0;
            IMC_sel = 0;
            state_sel = mode ? 2'd1 : 2'd3;
            Rd_Addr = mode ? count : (4'd10 - count);
            read_en = 1;
            // if (mode) begin
            //     ARK_sel = 3'b011;
            //     SB_sel  = 2'b01;
            //     SR_sel  = 1;
            //     ISR_sel = 0;
            //     MC_sel  = 0;
            //     IMC_sel = 0;
            // end
            // else begin
            //     ARK_sel = 3'b100;
            //     SB_sel  = 2'b00;
            //     SR_sel  = 0;
            //     ISR_sel = 0;
            //     MC_sel  = 0;
            //     IMC_sel = 0;
            // end
        end
        FINAL: begin
            ARK_sel = 'b0;
            IARK_sel = 'b0;
            SB_sel  = 'b0;
            SR_sel  = 0;
            ISR_sel = 0;
            MC_sel  = 0;
            IMC_sel = 0;
            Data_sel = 0;
            state_sel = 'b0;
            out_sel = 1;
            ARK_key_sel = 'b0;
            IARK_key_sel = 'b0;
            done = 1;
            Rd_Addr = 0;
            read_en = 0;
        end
        default: begin
            ARK_sel = 'b0;
            IARK_sel = 'b0;
            SB_sel  = 'b0;
            SR_sel  = 0;
            ISR_sel = 0;
            MC_sel  = 0;
            IMC_sel = 0;
            Data_sel = 0;
            state_sel = 'b0;
            out_sel = 0;
            ARK_key_sel = 'b0;
            IARK_key_sel = 'b0;
            done = 0;
            Rd_Addr = 0;
            read_en = 0;
        end
    endcase
end


// Counter for Read Address access for key from Key scheduler
always @ (posedge crypto_clk or negedge crypto_rstn) begin
    if(!crypto_rstn) begin
        count <= 'b0;
    end
    else if (temp3) begin
        count <= 'b0;
    end
    else count <= count + 1;
end

assign temp3 = (PS == IDLE) || (PS == FINAL) || count11 ;
assign count11 = (count == 4'd10);

endmodule