module AES_Datapath_v2 (
    input wire crypto_clk, crypto_rstn,
    input wire mode,                // mode = 1 -> Encryption | mode = 0 -> Decryption
    input wire zeroize,
    input wire [127:0] key_in,      // round key from Key scheduler
    input wire [127:0] Data_in,     // Plaintext/Ciphertext
//Control signals from Controller//
    input wire [2:0] ARK_sel, IARK_sel,
    input wire [1:0] SB_sel, state_sel,
    input wire SR_sel, ISR_sel, MC_sel, IMC_sel, Data_sel, out_sel, ARK_key_sel, IARK_key_sel,
//Data output from AES//    
    output wire [127:0] Data_out
//To the controller//
//    output wire mode_out
);

/*Temporory wires*/
wire [127:0] Din_reg, Dout_reg, state_in, state_reg;
wire [127:0] ARK_A, ARK_key, IARK_key, ARK_Q, IARK_A, IARK_Q;
wire [127:0] SB_A, SB_Q, SR_A, SR_Q, MC_A, MC_Q, IMC_A, IMC_Q, ISR_A, ISR_Q;
//wire mode_in;
wire [127:0] temp_reg_in, temp_reg_out;


// Datapath modules instantiation
//-----------------------------------------------------------------------------------------------------
/*Input registers*/
Reg_128 I1(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .zeroize(zeroize), .D_in(Din_reg), .D_out(Dout_reg));

//Reg_1   I2(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .D_in(mode_in), .D_out(mode_out));

//Reg_128 I3(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .D_in(key_in_reg), .D_out(key_out_reg));

// Ecryption Round Transformations//
/*Add Round Key*/
AddRoundKey U1(.A(ARK_A), .key(ARK_key), .Q(ARK_Q));

//SubBytes//
SubBytes U2 (.A(SB_A), .mode(mode), .Q(SB_Q));

//ShiftRows//
ShiftRows U3(.A(SR_A), .Q(SR_Q));

//Mix Columns//
MixColumns U4(.A(MC_A), .Q(MC_Q));

//Decryption Round Transformations:
//Add Round Key for Decryption//
AddRoundKey U5(.A(IARK_A), .key(IARK_key), .Q(IARK_Q));

/*Including the SubBytes() part also, since it has support on both encryption & decryption, 
so I've used the module for both*/

//Inverse Shift Rows//
InvShiftRows U6(.A(ISR_A), .Q(ISR_Q));

//Inverse Mix Columns//
InvMixColumns U7(.A(IMC_A), .Q(IMC_Q));

//State Register//
Reg_128 O1(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .zeroize(zeroize), .D_in(state_in), .D_out(state_reg));

//----------------------------------------------------------------------------------------------------------

//wire connection logic//
assign Din_reg = Data_sel ? Data_in :   // Registering the input data (If I change the data in mid_operation it won't affect the functionality)
                     Dout_reg;

//assign mode_in = mode_sel ? mode :      // Registering the mode (If I change the mode in mid_operation it won't affect the functionality)
//                     mode_out;

//assign key_in_reg = key_sel ? key_in :      // Registering the key which is from the key Storage Register (Input to this module & Output from the Key scheduler module)
//                    key_out_reg;

assign ARK_A = (ARK_sel == 2'd1) ? Dout_reg :  // Encryption:  round0 Data in --> AddRoundKey
               (ARK_sel == 2'd2) ? MC_Q :          // Encryption: Round 1-9 MixColumns --> AddRoundKey
               (ARK_sel == 2'd3) ? SR_Q :          // Encryption: Round 10 ShiftRows --> AddRoundKey
               'b0;                                // Otherwise: 0

assign ARK_key = ARK_key_sel ? key_in : 'b0;   // Depends on the ARK_key_sel signal (from the AES_Controller), selects the key value. (This is for Encryption)

assign SB_A = (SB_sel == 2'd1) ? state_reg :        // Encryption: State reg --> SubBytes
              (SB_sel == 2'd2) ? IARK_Q :           // Decryption: Round0: AddRoundKey (IARK) --> SubBytes
              (SB_sel == 2'd3) ? IMC_Q :            // Decryprion: Round 1-9 : Inv Mixcolumns --> SubBytes
              'b0;                                  // Otherwise: 0

assign SR_A = SR_sel ? SB_Q : 'b0;      // Encryption: SubBytes --> ShiftRows for R1-9, R10

assign ISR_A = ISR_sel ? SB_Q : 'b0;    // Decryption: SubBytes --> Inv ShiftRows for R0, R1-9

assign MC_A = MC_sel ? SR_Q : 'b0;      // Encryption: ShiftRows --> MixColumns for R1-9

assign IMC_A = IMC_sel ? IARK_Q : 'b0;  // Decryption: AddRoundKey --> Inv MixColumns for R1-9

assign IARK_A = (IARK_sel == 2'd1) ? Dout_reg :   // Decryption: round0: Data in --> AddRoundKey
                (IARK_sel == 2'd2) ? state_reg :        // Decryption: For 1-9,10 rounds state_reg --> AddRoundKey
                'b0;    
assign IARK_key = IARK_key_sel ? key_in : 'b0;     // Key selection based on the IARK_key_sel (This is for Decryption)

assign state_in = (state_sel == 2'd1) ? ARK_Q :     // Encryption: All rounds
                  (state_sel == 2'd2) ? ISR_Q :     // Decryption: round0, R1-9
                  (state_sel == 2'd3) ? IARK_Q :    // Decryption: Round-10
                  'b0;                              // Otherwise: 0

assign temp_reg_in = out_sel ? state_reg : temp_reg_out;    // Output Registering
assign Data_out = temp_reg_out;

Reg_128 O2(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .zeroize(zeroize), .D_in(temp_reg_in), .D_out(temp_reg_out));
endmodule