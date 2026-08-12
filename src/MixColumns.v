module MixColumns (
    input wire [127:0] A,
    output wire [127:0] Q
);


function automatic [7:0] mul2 (input [7:0] A);
    mul2 = A[7] ? (({A[6:0], 1'b0}) ^ (8'b00011011)) : ({A[6:0], A[7]});
endfunction

function automatic [7:0] mul3 (input [7:0] A);
    mul3 = mul2(A) ^ A;
endfunction

//Column 1
assign Q[127:120] = (mul2(A[127:120])) ^ (mul3(A[119:112])) ^ A[111:104] ^ A[103:96];
assign Q[119:112] = A[127:120] ^ (mul2(A[119:112])) ^ (mul3(A[111:104])) ^ A[103:96];
assign Q[111:104] = A[127:120] ^ A[119:112] ^ (mul2(A[111:104])) ^ (mul3(A[103:96]));
assign Q[103:96]  = (mul3(A[127:120])) ^ A[119:112] ^ A[111:104] ^ (mul2(A[103:96]));
//Column 2
assign Q[95:88]   = (mul2(A[95:88])) ^ (mul3(A[87:80])) ^ A[79:72] ^ A[71:64];
assign Q[87:80]   = A[95:88] ^ (mul2(A[87:80])) ^ (mul3(A[79:72])) ^ A[71:64];
assign Q[79:72]   = A[95:88] ^ A[87:80] ^ (mul2(A[79:72])) ^ (mul3(A[71:64]));
assign Q[71:64]   = (mul3(A[95:88])) ^ A[87:80] ^ A[79:72] ^ (mul2(A[71:64]));
//Column 3
assign Q[63:56]   = (mul2(A[63:56])) ^ (mul3(A[55:48])) ^ A[47:40] ^ A[39:32];
assign Q[55:48]   = A[63:56] ^ (mul2(A[55:48])) ^ (mul3(A[47:40])) ^ A[39:32];
assign Q[47:40]   = A[63:56] ^ A[55:48] ^ (mul2(A[47:40])) ^ (mul3(A[39:32]));
assign Q[39:32]   = (mul3(A[63:56])) ^ A[55:48] ^ A[47:40] ^ (mul2(A[39:32]));
//Column 4
assign Q[31:24]   = (mul2(A[31:24])) ^ (mul3(A[23:16])) ^ A[15:8] ^ A[7:0];
assign Q[23:16]   = A[31:24] ^ (mul2(A[23:16])) ^ (mul3(A[15:8])) ^ A[7:0];
assign Q[15:8]    = A[31:24] ^ A[23:16] ^ (mul2(A[15:8])) ^ (mul3(A[7:0]));
assign Q[7:0]     = (mul3(A[31:24])) ^ A[23:16] ^ A[15:8] ^ (mul2(A[7:0]));

endmodule