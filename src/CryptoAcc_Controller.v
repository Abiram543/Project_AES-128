module CryptoAcc_Controller (
    input wire crypto_clk, crypto_rstn,
    input wire start, start_aes,
    input wire fifo_empty_flag,
    input wire next_process,
    output reg [3:0] Rd_Addr,
    output reg read_en, busy_flag, done_flag
);
/*INternal wire */
wire next_process;

/* local parameterization */
localparam IDLE      = 2'd0,
           Key_INIT  = 2'd1,
           AES_Round = 2'd2,
           Done      = 2'd3;


/* Registers declarations */           
reg [1:0] PS, NS;

/* Present state logic */
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if (!crypto_rstn) begin
        PS <= IDLE;
    end
    else begin
        PS <= NS;
    end
end

/* Next state logic */
always @(*) begin
    case (PS)
        IDLE:       NS = start ? Key_INIT : IDLE;
        Key_INIT:   NS = start_aes ? AES_Round : Key_INIT;
        AES_Round:  NS = next_process ? AES_Round : Done;
        Done:       NS = IDLE;
        default: NS = IDLE;
    endcase
end

/* Next process logic */
assign next_process = !fifo_empty_flag;     // The next process value direct opp. of the empty_flag value of the Tx FIFO.

reg [3:0] count;
/* Counter for 11 cycles 0-11*/
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if (!crypto_rstn) begin
        count <= 'b0;
    end
    else begin
        if (count11) begin
            count <= 'b0;
        end
        else begin
            count <= count + 1;
        end
    end
end
// Temporory assignment for this equality comparator//
assign count11 = (count == 4'd11);

// Control signals generation //
always @(*) begin
    case (PS)
        IDLE: begin
            Rd_Addr = 4'd0;
            read_en = 0;
            busy_flag = 0;
            done_flag = 0;
        end 
        Key_INIT: begin
            Rd_Addr = 4'd0;
            read_en = 0;
            busy_flag = 1;
            done_flag = 0;
        end
        AES_Round: begin
            Rd_Addr = count;
            read_en = 1;
            busy_flag = 1;
            done_flag = 0;
        end
        Done: begin
            Rd_Addr = 4'd0;
            read_en = 0;
            done_flag = 1;
            busy_flag = 0;
        end
        default: begin
            Rd_Addr = 4'd0;
            read_en = 0;
            busy_flag = 0;
            done_flag = 0;
        end
    endcase
end

endmodule