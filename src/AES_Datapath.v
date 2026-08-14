module AES_Datapath_v2 (
    input wire crypto_clk, crypto_rstn,
    input wire mode,    // mode = 1 -> Encryption | mode = 0 -> Decryption
    input wire [127:0] key_in,     // round key from Key scheduler
    input wire [127:0] Data_in,  // Plaintext/Ciphertext
//------------Control signals from Controller---------//
    input wire [2:0] ARK_sel,
    input wire [1:0] SB_sel, state_sel,
    input wire SR_sel, ISR_sel, MC_sel, IMC_sel, Data_sel, mode_sel, out_sel, ARK_key_sel,
//--------------Data output from AES------//    
    output wire [127:0] Data_out,
//--------------To the controller---------//
    output wire mode_out_reg
);

//---------------Temporory wires--------------------//
wire [127:0] Data_in_reg, Data_out_reg, mode_in_reg, mode_out_reg, state_in, state_reg;
wire [127:0] ARK_A, ARK_key, ARK_Q;
wire [127:0] SB_A, SB_Q, SR_A, SR_Q, MC_A, MC_Q, IMC_A, IMC_Q, ISR_A, ISR_Q;



//---------------Input registers---------------//
Reg_128 I1(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .D_in(Data_in_reg), .D_out(Data_out_reg));

Reg_1   I2(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .D_in(mode_in_reg), .D_out(mode_out_reg));

//-----------------Add Round Key------------------//
AddRoundKey U1(.A(ARK_A), .key(ARK_key), .Q(ARK_Q));

//---------------SubBytes-----------------//
SubBytes U2 (.A(SB_A), .mode(mode_out_reg), .Q(SB_Q));

//--------------ShiftRows---------------//
ShiftRows U3(.A(SR_A), .Q(SR_Q));

//-------------Mix Columns---------------//
MixColumns U4(.A(MC_A), .Q(MC_Q));

//-------------Inverse Shift Rows------------//
InvShiftRows U5(.A(ISR_A), .Q(ISR_Q));

//-------------Inverse Mix Columns---------------//
InvMixColumns U6(.A(IMC_A), .Q(IMC_Q));

//------------------------State Register---------------------------------------------//
Reg_128 O1(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .D_in(state_in), .D_out(state_reg));

//--------------wire connection logic-----------------//
assign Data_in_reg = Data_sel ? Data_in : Data_out_reg;

assign mode_in_reg = mode_sel ? mode : mode_out_reg;

assign ARK_A = (ARK_sel == 3'd1) ? Data_out_reg : (ARK_sel == 3'd3) ? SR_Q : (ARK_sel == 3'd2) ? MC_Q : (ARK_sel == 3'd4) ? state_reg : 'b0;
assign ARK_key = ARK_key_sel ? key_in : 'b0;

assign SB_A = (SB_sel == 2'd1) ? state_reg : (SB_sel == 2'd2) ? ARK_Q : (SB_sel == 2'd3) ? IMC_Q : 'b0;

assign SR_A = SR_sel ? SB_Q : 'b0;

assign ISR_A = ISR_sel ? SB_Q : 'b0;

assign MC_A = MC_sel ? SR_Q : 'b0;

assign IMC_A = IMC_sel ? ARK_Q : 'b0;

assign state_in = (state_sel == 2'b01) ? ARK_Q : (state_sel == 2'b10) ? ISR_Q : 'b0;

assign Data_out = out_sel ? state_reg : 'b0;

endmodule