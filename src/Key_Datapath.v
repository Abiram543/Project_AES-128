module Key_Datapath (
    input wire crypto_clk, crypto_rstn,
    input wire [127:0] Key,
    input wire mode, zeroize, key_lock,
    input wire key_reg_sel, read_en, write_en, 
    input wire KE_sel,
    input wire [3:0] Wr_Addr, Rd_Addr,
    input wire key_store_done,
    output wire key_written,
    output wire [127:0] Read_data
);

wire [127:0] KE_in, KE_out, KR_in, KR_out, reg_in, reg_out;
wire done_reg_out, done_reg_in;

KeyExpansion KExp(.key_in(KE_in), 
                  .mode(mode), 
                  .roundVal(Wr_Addr+1), 
                  .key_out(KE_out)
                );

Key_ROM KRom(.crypto_clk(crypto_clk), 
             .crypto_rstn(crypto_rstn), 
             .zeroize(zeroize), 
             .write_en(write_en), 
             .key_lock(key_lock), 
             .read_en(read_en), 
             .write_data(KR_in), 
             .read_data(KR_out), 
             .Wr_Addr(Wr_Addr), 
             .Rd_Addr(Rd_Addr)
             );

//------------------------Key Register for feedback---------------------------------------------//
Reg_128 R128(.crypto_clk(crypto_clk), 
             .crypto_rstn(crypto_rstn), 
             .D_in(reg_in), 
             .D_out(reg_out)
             );

Reg_1 R1(.crypto_clk(crypto_clk), 
             .crypto_rstn(crypto_rstn), 
             .D_in(done_reg_in), 
             .D_out(done_reg_out)
             );
            

assign KE_in = (KE_sel) ? reg_out :  Key ;
assign KR_in = write_en ? reg_out : 'b0;
assign reg_in = zeroize ? 'b0 : 
                !key_reg_sel ? Key :
                KE_out;

assign Read_data = KR_out;
assign done_reg_in = key_store_done ? 1 : done_reg_out;     // Detect once keys are loaded into ROM
assign key_written = done_reg_out;          // Key store operation done

endmodule