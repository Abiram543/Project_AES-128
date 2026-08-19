module Key_scheduler (
    input wire crypto_clk, crypto_rstn,
    input wire mode,
    input wire [127:0] Key,     // Original private key
    output wire [127:0] Roundkey    // Round keys for each rounds 0-10
);
    
endmodule