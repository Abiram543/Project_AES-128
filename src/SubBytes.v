module SubBytes (
    input wire [127:0] A,
    input wire mode,
    output wire [127:0] Q
);

//S-Box Instantiation
sbox_comb U1 (.A(A[7:0]), .encrypt(mode), .Q(Q[7:0]));
sbox_comb U2 (.A(A[15:8]), .encrypt(mode), .Q(Q[15:8]));
sbox_comb U3 (.A(A[23:16]), .encrypt(mode), .Q(Q[23:16]));
sbox_comb U4 (.A(A[31:24]), .encrypt(mode), .Q(Q[31:24]));
sbox_comb U5 (.A(A[39:32]), .encrypt(mode), .Q(Q[39:32]));
sbox_comb U6 (.A(A[47:40]), .encrypt(mode), .Q(Q[47:40]));
sbox_comb U7 (.A(A[55:48]), .encrypt(mode), .Q(Q[55:48]));
sbox_comb U8 (.A(A[63:56]), .encrypt(mode), .Q(Q[63:56]));
sbox_comb U9 (.A(A[71:64]), .encrypt(mode), .Q(Q[71:64]));
sbox_comb U10(.A(A[79:72]), .encrypt(mode), .Q(Q[79:72]));
sbox_comb U11(.A(A[87:80]), .encrypt(mode), .Q(Q[87:80]));
sbox_comb U12(.A(A[95:88]), .encrypt(mode), .Q(Q[95:88]));
sbox_comb U13(.A(A[103:96]), .encrypt(mode), .Q(Q[103:96]));
sbox_comb U14(.A(A[111:104]), .encrypt(mode), .Q(Q[111:104]));
sbox_comb U15(.A(A[119:112]), .encrypt(mode), .Q(Q[119:112]));
sbox_comb U16(.A(A[127:120]), .encrypt(mode), .Q(Q[127:120]));
    
endmodule