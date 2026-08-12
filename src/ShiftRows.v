module ShiftRows (
    input wire [127:0] A,
    output wire [127:0] Q
);

// Shifting the rows based on the procedure. Refer the AES-128 FIPS 197 Manual
assign Q[127:120] = A[127:120]; //  Q1
assign Q[119:112] = A[87:80];   //  Q2
assign Q[111:104] = A[47:40];   //  Q3
assign Q[103:96]  = A[7:0];     //  Q4
assign Q[95:88]   = A[95:88];   //  Q5
assign Q[87:80]   = A[55:48];   //  Q6
assign Q[79:72]   = A[15:8];    //  Q7
assign Q[71:64]   = A[103:96];  //  Q8
assign Q[63:56]   = A[63:56];   //  Q9
assign Q[55:48]   = A[23:16];   //  Q10
assign Q[47:40]   = A[111:104]; //  Q11
assign Q[39:32]   = A[71:64];   //  Q12
assign Q[31:24]   = A[31:24];   //  Q13
assign Q[23:16]   = A[119:112]; //  Q14
assign Q[15:8]    = A[79:72];   //  Q15
assign Q[7:0]     = A[39:32];   //  Q16

endmodule