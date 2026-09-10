module AES_core (
    input wire crypto_clk, crypto_rstn,
    input wire start,            // Start the AES process
    input wire mode,
    input wire [127:0] key_in,     // round key from Key scheduler
    input wire [127:0] Data_in,  // Plaintext/Ciphertext
//--------------Data output from AES------//
    output wire [127:0] Data_out,
//-------------status signal---------------//
    output wire aes_done,
    output wire [3:0] Rd_Addr,
    output wire read_en
);

wire [2:0] ARK_sel, IARK_sel;
wire [1:0] SB_sel, state_sel;
wire SR_sel, ISR_sel, MC_sel, IMC_sel, Data_sel, out_sel, ARK_key_sel, IARK_key_sel;

AES_Controller_v2 AES_Ctrl(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .start(start), .mode(mode), .ARK_sel(ARK_sel), .SB_sel(SB_sel), .state_sel(state_sel), 
                        .Rd_Addr(Rd_Addr), .read_en(read_en), .IARK_sel(IARK_sel), .ARK_key_sel(ARK_key_sel), .IARK_key_sel(IARK_key_sel), .out_sel(out_sel), .SR_sel(SR_sel), .ISR_sel(ISR_sel), .MC_sel(MC_sel), .IMC_sel(IMC_sel), .Data_sel(Data_sel), .done(aes_done));

AES_Datapath_v2 AES_Dtp(.crypto_clk(crypto_clk), .crypto_rstn(crypto_rstn), .mode(mode), .key_in(key_in), .Data_in(Data_in), .ARK_sel(ARK_sel), .SB_sel(SB_sel), .state_sel(state_sel), 
                        .IARK_sel(IARK_sel), .ARK_key_sel(ARK_key_sel), .IARK_key_sel(IARK_key_sel), .out_sel(out_sel), .SR_sel(SR_sel), .ISR_sel(ISR_sel), .MC_sel(MC_sel), .IMC_sel(IMC_sel), .Data_sel(Data_sel), .Data_out(Data_out));
    
endmodule