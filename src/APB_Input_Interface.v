module APB_Input_Interface (
    input  wire        PCLK,
    input  wire        PRESETn,

    input  wire [7:0]  PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PWDATA,
    input  wire [2:0]  PPROT,
    
    input wire         Rx_empty_delay,  // Comes from Rx-FIFO Empty signal delayed 
    input wire         Tx_full,
    input wire [127:0] Rx_Data_out,
    input wire         done_flag_sync, busy_flag_sync,  // Comes from Core --> Synchronized with pclk domain  

    output reg  [127:0] privatekey,
    output reg          Key_Valid,
    output reg  [127:0] plaintxt,
    output reg          Data_Valid,
    output reg          mode,
    output reg          mode_Valid,
    output reg          KEYLOCK,
    output reg          ZEROIZE,
    output reg          START,
    output reg          SEC_VIOLATION,
    output reg          PSLVERR,
    output reg          PRDATA,
    output reg          READ_POP
);

// Register Map
localparam ADDR_CONTROL     = 8'h00,
           ADDR_STATUS      = 8'h04,
 
           ADDR_KEY0        = 8'h08,
           ADDR_KEY1        = 8'h0C,
           ADDR_KEY2        = 8'h10,
           ADDR_KEY3        = 8'h14,
           
           ADDR_DATA_IN0    = 8'h18,
           ADDR_DATA_IN1    = 8'h1C,
           ADDR_DATA_IN2    = 8'h20,
           ADDR_DATA_IN3    = 8'h24,

           ADDR_DATA_OUT0   = 8'h28,
           ADDR_DATA_OUT1   = 8'h2C,
           ADDR_DATA_OUT2   = 8'h30,
           ADDR_DATA_OUT3   = 8'h34
           
           ADDR_READ_POP    = 8'h38;

// Registers
reg [31:0] KEY0;
reg [31:0] KEY1;
reg [31:0] KEY2;
reg [31:0] KEY3;

reg [31:0] DATA_IN0;
reg [31:0] DATA_IN1;
reg [31:0] DATA_IN2;
reg [31:0] DATA_IN3;

// AES output registers
reg [31:0] DATA_OUT0;
reg [31:0] DATA_OUT1;
reg [31:0] DATA_OUT2;
reg [31:0] DATA_OUT3;

reg DONE, BUSY;
// Temp reg
reg keylock;

reg READ_POP;


// Write operation can start when apb_write is valid & 
//Read operation can start when apb_read is valid
wire apb_write, apb_read;

assign apb_write = PSEL && PENABLE && PWRITE && !BUSY && !Tx_full;
assign apb_read  = PSEL && PENABLE && !PWRITE;

wire [127:0] KEY, DATA;
reg MODE;
// 32 bit to 128 bit Concatenation
assign KEY = {KEY0,
              KEY1,
              KEY2,
              KEY3};

assign DATA = {DATA_IN0,
               DATA_IN1,
               DATA_IN2,
               DATA_IN3};


//APB WRITE TRANSACTION
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        KEY0     <= 'b0;
        KEY1     <= 'b0;
        KEY2     <= 'b0;
        KEY3     <= 'b0;
        DATA_IN0 <= 'b0;
        DATA_IN1 <= 'b0;
        DATA_IN2 <= 'b0;
        DATA_IN3 <= 'b0;
        START    <= 'b0;
        MODE     <= 'b0;
        KEYLOCK  <= 'b0;
        ZEROIZE  <= 'b0; 
    end
    else if (ZEROIZE) begin
        KEY0     <= 'b0;
        KEY1     <= 'b0;
        KEY2     <= 'b0;
        KEY3     <= 'b0;
        DATA_IN0 <= 'b0;
        DATA_IN1 <= 'b0;
        DATA_IN2 <= 'b0;
        DATA_IN3 <= 'b0;
        START    <= 'b0;
        MODE     <= 'b0;
        KEYLOCK  <= 'b0;    
    end
    else begin
        if (apb_write && PPROT[0]) begin
            case (PADDR)
                ADDR_CONTROL:begin
                    START   <= PWDATA[0];
                    MODE    <= !keylock ? PWDATA[1] : MODE;
                    KEYLOCK <= PWDATA[2];
                    ZEROIZE <= PWDATA[3];   
                end 
                ADDR_KEY0:begin
                    KEY0 <= !keylock ? PWDATA : KEY0;
                end
                ADDR_KEY1:begin
                    KEY1 <= !keylock ? PWDATA : KEY1;
                end
                ADDR_KEY2:begin
                    KEY2 <= !keylock ? PWDATA : KEY2;
                end
                ADDR_KEY3:begin
                    KEY3 <= !keylock ? PWDATA : KEY3;
                end
                ADDR_DATA_IN0:begin
                    DATA_IN0 <= PWDATA;
                end
                ADDR_DATA_IN1:begin
                    DATA_IN1 <= PWDATA;
                end
                ADDR_DATA_IN2:begin
                    DATA_IN2 <= PWDATA;
                end
                ADDR_DATA_IN3:begin
                    DATA_IN3 <= PWDATA;
                end
                ADDR_READ_POP:begin
                    READ_POP <= PWDATA[0];
                end
                default: begin
                   // nOTHING IS DONE
                end
            endcase
        end
    end

end

// word_Counter
reg [1:0] word_count;

always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        word_count <= 'b0;
    end
    else if (ZEROIZE) begin
        word_count <= 'b0;
    end
    else begin
        if (apb_write && PPROT[0]) begin
            if (word_count == 2'd3) begin
                word_count <= 'b0;
            end
            case (PADDR)
                ADDR_KEY0:begin
                    word_count <= 'b0;
                end
                ADDR_KEY1:begin
                    word_count <= 2'd1;
                end
                ADDR_KEY2:begin
                    word_count <= 2'd2;
                end
                ADDR_KEY3:begin
                    word_count <= 2'd3;
                end 
                ADDR_DATA_IN0:begin
                    word_count <= 'b0;
                end
                ADDR_DATA_IN1:begin
                    word_count <= 2'd1;
                end
                ADDR_DATA_IN2:begin
                    word_count <= 2'd2;
                end
                ADDR_DATA_IN3:begin
                    word_count <= 2'd3;
                end
                default: word_count <= 'b0;
            endcase
        end
    end
end

//Valid Signals logic
always @(posedge PCLK or negedge PRESETn ) begin
    if (!PRESETn) begin
        mode_Valid <= 'b0;
        Data_Valid <= 'b0;
        Key_Valid  <= 'b0;
    end
    else if (ZEROIZE) begin
        mode_Valid <= 'b0;
        Data_Valid <= 'b0;
        Key_Valid  <= 'b0;
    end
    else begin
        case (PADDR)
            ADDR_KEY3:begin
                Key_Valid <= (word_count == 2'd2);
                Data_Valid <= 'b0;
                mode_Valid <= 'b0;
            end 
            ADDR_DATA_IN3: begin
                Data_Valid <= (word_count == 2'd2);
                Key_Valid <= 'b0;
                mode_Valid <= 'b0;
            end
            ADDR_CONTROL: begin
                mode_Valid <= (PPROT[0] && !keylock);
                Data_Valid <= 'b0;
                Key_Valid <= 'b0;
            end
            default: begin
                mode_Valid <= 'b0;
                Data_Valid <= 'b0;
                Key_Valid  <= 'b0;
            end
        endcase
    end
end

// Keylock Logic
always @(posedge PCLK or negedge PRESETn ) begin
    if (!PRESETn) begin
        keylock <= 'b0;
    end
    else if (KEYLOCK) begin
        keylock <= 1;
    end
end

always @(posedge PCLK or negedge PRESETn ) begin
    if (!PRESETn) begin
        plaintxt <= 'b0;
        privatekey <= 'b0;
        mode <= 'b0;
    end
    else if (ZEROIZE) begin
        plaintxt <= 'b0;
        privatekey <= 'b0;
        mode <= 'b0;
    end
    else begin
        if(Data_Valid) begin
            plaintxt <= DATA;
        end
        if(Key_Valid) begin
            privatekey <= KEY;
        end
        if(mode_Valid) begin
            mode <= MODE;
        end
    end
end

// PSLVERR AND SEC_VIOLATION LOGIC
always @ * begin
    if(apb_read || apb_write) begin
        case (PADDR)
        ADDR_CONTROL, ADDR_KEY0, ADDR_KEY1, ADDR_KEY2, ADDR_KEY3, ADDR_DATA_IN0, ADDR_DATA_IN1, ADDR_DATA_IN2, ADDR_DATA_IN3:begin
            PSLVERR = PPROT[0] ? 0 : 1;
        end 
        ADDR_STATUS, ADDR_DATA_OUT0, ADDR_DATA_OUT1, ADDR_DATA_OUT2, ADDR_DATA_OUT3: begin
            PSLVERR = 0;
        end
        default: PSLVERR = 1;
        endcase
    end
    else PSLVERR = 0;
end

//SEC_VIOLATION logic
always @(posedge PCLK or negedge PRESETn ) begin
    if (!PRESETn) begin
        SEC_VIOLATION <= 'b0;
    end
    else begin
        SEC_VIOLATION <= PSLVERR ? 1'b1 : SEC_VIOLATION;
    end
end

// Output Read from Rx FIFO logic
reg [2:0] count;
// Rx Read ena logic
always @ (posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        count <= 'b0;
    end
    else begin
        if(!Rx_empty_delay && READ_POP && !PWRITE && Valid_Read)begin
            if(count == 3'd4)
                count <= 'b0;
            else
                count <= count + 1;
        end
        else count <= 'b0;
    end
end

assign Rx_rd_en = (count == 3'd4);

always @ (posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        {DATA_OUT0, DATA_OUT1, DATA_OUT2, DATA_OUT3} <= 'b0;
    end
    else if (Rx_rd_en) begin
        {DATA_OUT0, DATA_OUT1, DATA_OUT2, DATA_OUT3} <= Rx_Data_out;
    end
end 

// DONE signal logic
// BUSY signal logic
always @ (posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        DONE <= 0;
        BUSY <= 0;
    end
    else begin
        DONE <= done_flag_sync;
        BUSY <= busy_flag_sync;
    end
end

// PRDATA read Transaction
always @ (posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        PRDATA <= 'b0;
    end
    else begin
        if(apb_read) begin
            case(PADDR)
            ADDR_DATA_OUT0: begin
                PRDATA <= DATA_OUT0;
            end
            ADDR_DATA_OUT1: begin
                PRDATA <= DATA_OUT1;
            end
            ADDR_DATA_OUT2: begin
                PRDATA <= DATA_OUT2;
            end
            ADDR_DATA_OUT3: begin
                PRDATA <= DATA_OUT3;
            end
            ADDR_STATUS: begin
                PRDATA <= {30'd0, BUSY, DONE};
            end
            default: begin
                PRDATA <= 'b0; 
            end
            endcase
        end
end

always @ (*) begin
    if(apb_read) begin
        case(PADDR)
        ADDR_DATA_OUT0: begin
            Valid_Read = 1;
        end
        ADDR_DATA_OUT1: begin
            Valid_Read = 1;
        end
        ADDR_DATA_OUT2: begin
            Valid_Read = 1;
        end
        ADDR_DATA_OUT3: begin
            Valid_Read = 1;
        end
        ADDR_STATUS: begin
            Valid_Read = 0;
        end
        default: begin
            Valid_Read = 0;
        end
        endcase
    end
    else
        Valid_Read = 0;
    end
    
endmodule