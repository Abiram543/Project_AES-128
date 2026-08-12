module InvMixColumns (
    input wire [127:0] A,
    output wire [127:0] Q
);

function automatic [7:0] GFMul (input [7:0] A, input [3:0] B);
reg [7:0] A2, A4, A8;
 begin
    A2[7:0] = A[7] ? ({A[6:0], 1'b0} ^ 8'h1B) : {A[6:0], 1'b0};
    A4[7:0] = A2[7] ? ({A2[6:0], 1'b0} ^ 8'h1B) : {A2[6:0], 1'b0};
    A8[7:0] = A4[7] ? ({A4[6:0], 1'b0} ^ 8'h1B) : {A4[6:0], 1'b0};

    GFMul = (B[3] ? A8 : 8'h00) ^
            (B[2] ? A4 : 8'h00) ^
            (B[1] ? A2 : 8'h00) ^
            (B[0] ? A : 8'h00);
 end
endfunction

//Column 1
assign Q[127:120] = GFMul(A[127:120], 4'hE) ^
                    GFMul(A[119:112], 4'hB) ^
                    GFMul(A[111:104], 4'hD) ^
                    GFMul(A[103:96],  4'h9);
assign Q[119:112] = GFMul(A[127:120], 4'h9) ^
                    GFMul(A[119:112], 4'hE) ^
                    GFMul(A[111:104], 4'hB) ^
                    GFMul(A[103:96],  4'hD);
assign Q[111:104] = GFMul(A[127:120], 4'hD) ^
                    GFMul(A[119:112], 4'h9) ^
                    GFMul(A[111:104], 4'hE) ^
                    GFMul(A[103:96],  4'hB);
assign Q[103:96]  = GFMul(A[127:120], 4'hB) ^
                    GFMul(A[119:112], 4'hD) ^
                    GFMul(A[111:104], 4'h9) ^
                    GFMul(A[103:96],  4'hE);
//Column 2
assign Q[95:88]   = GFMul(A[95:88], 4'hE) ^
                    GFMul(A[87:80], 4'hB) ^
                    GFMul(A[79:72], 4'hD) ^
                    GFMul(A[71:64], 4'h9);
assign Q[87:80]   = GFMul(A[95:88], 4'h9) ^
                    GFMul(A[87:80], 4'hE) ^
                    GFMul(A[79:72], 4'hB) ^
                    GFMul(A[71:64], 4'hD);
assign Q[79:72]   = GFMul(A[95:88], 4'hD) ^
                    GFMul(A[87:80], 4'h9) ^
                    GFMul(A[79:72], 4'hE) ^
                    GFMul(A[71:64], 4'hB);
assign Q[71:64]   = GFMul(A[95:88], 4'hB) ^
                    GFMul(A[87:80], 4'hD) ^
                    GFMul(A[79:72], 4'h9) ^
                    GFMul(A[71:64], 4'hE);
//Column 3
assign Q[63:56]   = GFMul(A[63:56], 4'hE) ^
                    GFMul(A[55:48], 4'hB) ^
                    GFMul(A[47:40], 4'hD) ^
                    GFMul(A[39:32], 4'h9);
assign Q[55:48]   = GFMul(A[63:56], 4'h9) ^
                    GFMul(A[55:48], 4'hE) ^
                    GFMul(A[47:40], 4'hB) ^
                    GFMul(A[39:32], 4'hD);
assign Q[47:40]   = GFMul(A[63:56], 4'hD) ^
                    GFMul(A[55:48], 4'h9) ^
                    GFMul(A[47:40], 4'hE) ^
                    GFMul(A[39:32], 4'hB);
assign Q[39:32]   = GFMul(A[63:56], 4'hB) ^
                    GFMul(A[55:48], 4'hD) ^
                    GFMul(A[47:40], 4'h9) ^
                    GFMul(A[39:32], 4'hE);
//Column 4
assign Q[31:24]   = GFMul(A[31:24], 4'hE) ^
                    GFMul(A[23:16], 4'hB) ^
                    GFMul(A[15:8] , 4'hD) ^
                    GFMul(A[7:0]  , 4'h9);
assign Q[23:16]   = GFMul(A[31:24], 4'h9) ^
                    GFMul(A[23:16], 4'hE) ^
                    GFMul(A[15:8] , 4'hB) ^
                    GFMul(A[7:0]  , 4'hD);
assign Q[15:8]    = GFMul(A[31:24], 4'hD) ^
                    GFMul(A[23:16], 4'h9) ^
                    GFMul(A[15:8] , 4'hE) ^
                    GFMul(A[7:0]  , 4'hB);
assign Q[7:0]     = GFMul(A[31:24], 4'hB) ^
                    GFMul(A[23:16], 4'hD) ^
                    GFMul(A[15:8] , 4'h9) ^
                    GFMul(A[7:0]  , 4'hE);

endmodule
