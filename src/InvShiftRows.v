module InvShiftRows (
    input wire [127:0] A,
    output wire [127:0] Q
);

// First Row
assign Q[127:120] = A[127:120];
assign Q[95:88]   = A[95:88]  ;
assign Q[63:56]   = A[63:56]  ;
assign Q[31:24]   = A[31:24]  ;
// 2nd Row
assign Q[119:112] = A[23:16];
assign Q[87:80]   = A[119:112];
assign Q[55:48]   = A[87:80];
assign Q[23:16]   = A[55:48];
// 3rd Row
assign Q[111:104] = A[47:40];
assign Q[79:72]   = A[15:8];
assign Q[47:40]   = A[111:104];
assign Q[15:8]    = A[79:72];
// 4th Row
assign Q[103:96]  = A[71:64];
assign Q[71:64]   = A[39:32];
assign Q[39:32]   = A[7:0];
assign Q[7:0]     = A[103:96];

endmodule