//Golden Model for Data Cache

module data_cache_golden #(parameter b = 16, t = 20, i = 8, o = 4)( //Calculations in data sheet
    input logic [31:0] address,
    input logic rw_in, //If rw_in = 1 read, else if rw_in = 0 write
    input logic ar_wr_resp,
    input logic ar_rd_ack,
    input logic ar_wr_ack,
    input logic ar_wr_conf,
    input logic reset,
    input logic clk,

    inout logic [b-1:0] data_bus,

    output logic stall,
    output logic [31:0] data_out,
    output logic [31:0] ar_r_addr,
    output logic rd_rq,
    output logic wr_rq,
    output logic [31:0] ar_w_data,
    output logic [31:0] ar_w_addr
);

logic access; //Access
logic ar_rd_acc; //Read Access?
logic ar_wr_acc; //Write Access?

//Cache Controller FSM 
typedef enum logic [1:0] {
    IDLE = 2'b00,
    ACCESS = 2'b01,
    WRITEBACK = 2'b10,
    MISSREPAIR = 2'b11
} state_t;
state_t current, next;


//Extract Tag, Index, and Offset
logic tag [t-1:0] = address[31:12];
logic index [i-1:0] = address[11:4];
logic offset [o-1:0] = address[3:0];

//Read Hit vs Read Miss Behavior









endmodule