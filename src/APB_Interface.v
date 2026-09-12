module APB_Interface (
    input  wire        PCLK,
    input  wire        PRESETn,

    input  wire [7:0]  PADDR,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [31:0] PWDATA,
    input  wire [3:0]  PSTRB,
    input  wire [2:0]  PPROT,
    
    input wire done_flag_sync, busy_flag_sync,
    input wire [127:0] RxData_out,

    output reg  [31:0] PRDATA,
    output wire        PREADY,
    output reg         PSLVERR,
    output reg         SEC_VIOLATION,
    output wire [127:0] KEY,
    output wire [127:0] DATA,
    output reg          START, 
    output reg          MODE,
    output reg          KEYLOCK,
    output reg          ZEROIZE,
    output reg          DATA_WRITE_DONE,
    output reg          DONE
);


wire apb_write;
wire apb_read;

assign apb_write = PSEL && PENABLE && PWRITE;
assign apb_read  = PSEL && PENABLE && !PWRITE;

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

           ADDR_DATA_WRITE_DONE  = 8'h38,       // Once Data write done the master hase to send ACK

           ADDR_DATA_OUT0   = 8'h28,
           ADDR_DATA_OUT1   = 8'h2C,
           ADDR_DATA_OUT2   = 8'h30,
           ADDR_DATA_OUT3   = 8'h34;


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

reg        DONE;
reg        BUSY;

assign KEY = {KEY0,
              KEY1,
              KEY2,
              KEY3};

assign DATA = {DATA_IN0,
               DATA_IN1,
               DATA_IN2,
               DATA_IN3};

assign PREADY = done_flag_sync;     


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
    else begin
        START <= 'b0;
        if (apb_write) begin
            case (PADDR)
                ADDR_CONTROL:begin
                    START   <= PPROT[0] ? PWDATA[0] : START  ;
                    MODE    <= PPROT[0] ? PWDATA[1] : MODE   ;
                    KEYLOCK <= PPROT[0] ? PWDATA[2] : KEYLOCK;
                    ZEROIZE <= PPROT[0] ? PWDATA[3] : ZEROIZE;   
                end 
                ADDR_KEY0:begin
                    KEY0 <= PPROT[0] ? PWDATA : KEY0;
                end
                ADDR_KEY1:begin
                    KEY1 <= PPROT[0] ? PWDATA : KEY1;
                end
                ADDR_KEY2:begin
                    KEY2 <= PPROT[0] ? PWDATA : KEY2;
                end
                ADDR_KEY3:begin
                    KEY3 <= PPROT[0] ? PWDATA : KEY3;
                end
                ADDR_DATA_IN0:begin
                    DATA_IN0 <= PPROT[0] ? PWDATA : DATA_IN0;
                end
                ADDR_DATA_IN1:begin
                    DATA_IN1 <= PPROT[0] ? PWDATA : DATA_IN1;
                end
                ADDR_DATA_IN2:begin
                    DATA_IN2 <= PPROT[0] ? PWDATA : DATA_IN2;
                end
                ADDR_DATA_IN3:begin
                    DATA_IN3 <= PPROT[0] ? PWDATA : DATA_IN3;
                end
                ADDR_DATA_WRITE_DONE:begin
                    DATA_WRITE_DONE <= PPROT[0] ? PWDATA[0] : 0;
                end
                default: begin
                   // nOTHING IS DONE
                end
            endcase
        end
    end

end

// Output data reads from Rx-FIFO
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        DATA_OUT0 <= 32'b0;
        DATA_OUT1 <= 32'b0;
        DATA_OUT2 <= 32'b0;
        DATA_OUT3 <= 32'b0;
        DONE <= 1'b0;
        BUSY <= 1'b0;
    end
    else begin
        DONE <= done_flag_sync;
        BUSY <= busy_flag_sync;
        if (done_flag_sync) begin
        DATA_OUT0 <= RxData_out[31:0];
        DATA_OUT1 <= RxData_out[63:32];
        DATA_OUT2 <= RxData_out[95:64];
        DATA_OUT3 <= RxData_out[127:96];
        end
    end
end

//APB Read operation
always @(*) begin
    PRDATA = 'b0;
    if (apb_read) begin
        case (PADDR)
            ADDR_CONTROL: begin
                PRDATA = PPROT[0] ? {28'd0, ZEROIZE, KEYLOCK, MODE, START} : 'b0;
            end
            ADDR_STATUS: begin
                PRDATA = {30'd0, BUSY, DONE};
            end
            ADDR_KEY0, ADDR_KEY1, ADDR_KEY2, ADDR_KEY3: begin
                PRDATA = 'b0;
            end
            ADDR_DATA_IN0: begin
                PRDATA = PPROT[0] ? DATA_IN0 : 'b0;
            end
            ADDR_DATA_IN1: begin
                PRDATA = PPROT[0] ? DATA_IN1 : 'b0;
            end
            ADDR_DATA_IN2: begin
                PRDATA = PPROT[0] ? DATA_IN2 : 'b0;
            end
            ADDR_DATA_IN3: begin
                PRDATA = PPROT[0] ? DATA_IN3 : 'b0;
            end
            ADDR_DATA_OUT0: begin
                PRDATA = DATA_OUT0;
            end
            ADDR_DATA_OUT1: begin
                PRDATA = DATA_OUT1;
            end
            ADDR_DATA_OUT2: begin
                PRDATA = DATA_OUT2;
            end
            ADDR_DATA_OUT3: begin
                PRDATA = DATA_OUT3;
            end
            default: PRDATA = 'b0;
        endcase
    end
end

// PSLVERR AND SEC_VIOLATION LOGIC
always @ * begin
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

//SEC_VIOLATION logic
always @(posedge PCLK or negedge PRESETn ) begin
    if (!PRESETn) begin
        SEC_VIOLATION <= 'b0;
    end
    else begin
        SEC_VIOLATION <= PSLVERR ? 1'b1 : SEC_VIOLATION;
    end
end

endmodule