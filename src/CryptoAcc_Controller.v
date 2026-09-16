module CryptoAcc_Controller (
    input wire crypto_clk, crypto_rstn,
    input wire start, aes_done, zeroize,
    input wire fifo_empty_flag, 
    input wire key_written, key_store_done,
    output reg busy_flag, done_flag, start_aes
);
/*INternal wire */
//wire next_process;

/* local parameterization */
localparam IDLE      = 3'd0,
           Key_INIT  = 3'd1,
           AES_Round = 3'd2,
           Data_reg  = 3'd3,
           Done      = 3'd4;


/* Registers declarations */           
reg [2:0] PS, NS;

/* Present state logic */
always @(posedge crypto_clk or negedge crypto_rstn) begin
    if (!crypto_rstn) begin
        PS <= IDLE;
    end
    else if (zeroize) begin
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
        Key_INIT:   NS = key_store_done ? AES_Round : Key_INIT;
        AES_Round:  NS = !aes_done ? AES_Round : Data_reg;
        Data_reg:   NS = fifo_empty_flag ? Done : key_written ? AES_Round : Done;
        Done:       NS = IDLE;
        default: NS = IDLE;
    endcase
end

/* Next process logic */
//assign next_process = !fifo_empty_flag && !aes_done;     // The next process value direct opp. of the empty_flag value of the Tx FIFO.

//reg [3:0] count;
///* Counter for 11 cycles 0-11*/
//always @(posedge crypto_clk or negedge crypto_rstn) begin
//    if (!crypto_rstn) begin
//        count <= 'b0;
//    end
//    else if(PS == AES_Round) begin
//        if (count11) begin
//            count <= 'b0;
//        end
//        else begin
//            count <= count;
//        end
//    end
//    else count <= 'b0;
//end
//// Temporory assignment for this equality comparator//
//assign count11 = (count == 4'd11);

// Control signals generation //
always @(*) begin
    case (PS)
        IDLE: begin
            busy_flag = 0;
            done_flag = 1;
            start_aes = 0;
        end 
        Key_INIT: begin
            busy_flag = 1;
            done_flag = 0;
            start_aes = key_store_done;
        end
        AES_Round: begin
            busy_flag = 1;
            done_flag = 0;
            start_aes = 0;
        end
        Data_reg: begin
            busy_flag = 1;
            done_flag = 0;
            start_aes = (!fifo_empty_flag && key_written);
        end
        Done: begin
            busy_flag = 0;
            done_flag = 1;
            start_aes = 0;
        end
        default: begin
            busy_flag = 0;
            done_flag = 1;
            start_aes = 0;
        end
    endcase
end

endmodule