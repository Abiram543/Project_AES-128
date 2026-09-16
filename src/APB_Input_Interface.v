module APB_Input_Interface (
    input  wire        PCLK,
    input  wire        PRESETn,

    input  wire [7:0]  PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PWDATA,
    input  wire [2:0]  PPROT,

    output reg  [127:0] privatekey,
    output reg          Key_Valid,
    output reg  [127:0] plaintxt,
    output reg          Data_Valid,
    output reg          mode,
    output reg          mode_Valid,
    output reg          KEYLOCK,
    output reg          ZEROIZE,
    output reg          START
);

// Register Map
localparam ADDR_CONTROL     = 8'h04,
 
           ADDR_KEY0        = 8'h08,
           ADDR_KEY1        = 8'h0C,
           ADDR_KEY2        = 8'h10,
           ADDR_KEY3        = 8'h14,
           
           ADDR_DATA_IN0    = 8'h18,
           ADDR_DATA_IN1    = 8'h1C,
           ADDR_DATA_IN2    = 8'h20,
           ADDR_DATA_IN3    = 8'h24;

// Registers
reg [31:0] KEY0;
reg [31:0] KEY1;
reg [31:0] KEY2;
reg [31:0] KEY3;

reg [31:0] DATA_IN0;
reg [31:0] DATA_IN1;
reg [31:0] DATA_IN2;
reg [31:0] DATA_IN3;

// Temp reg
reg keylock;


// Write operation can start when apb_write is valid
wire apb_write;

assign apb_write = PSEL && PENABLE && PWRITE;

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
                ADDR_KEY1, ADDR_KEY2, ADDR_KEY3:begin
                    word_count <= word_count + 1;
                end 
                ADDR_DATA_IN0:begin
                    word_count <= 'b0;
                end
                ADDR_DATA_IN1, ADDR_DATA_IN2, ADDR_DATA_IN3:begin
                    word_count <= word_count + 1;
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
    else if (ZEROIZE) begin
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

endmodule