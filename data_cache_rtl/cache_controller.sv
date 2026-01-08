//Cache Controller
module cache_controller #(parameter index_count = 256,
parameter data = 11, parameter tag = 20)
(
    input wire clk,
    input wire rst,
    input wire [31:0] address; //Address Input
    input wire lsu_operator, //Either LW or SW
    input wire mem_enable, //Enable Memory (Cache + DRAM) 

    input logic mem_ready, //Memory is Ready from the DRAM
    input logic [data-1:0] dram_data_input,

    output logic cache_enable, //Enable the Cache
    output logic [tag + data:0] write_index, //Write Data to the Cache {valid, tag, data}
    output logic [$clog2(index_count) - 1:0] index_sel, //Index Select
    output logic mem_req, //Request Data from the DRAM

    output wire stall, //Stall the Pipeline
    output wire [data-1:0] read_data
);


//Instantiate the Data Cache
data_cache #(
    .index_count(256),
    .data(11),
    .tag(20)
) dcache(
    .clk(clk),
    .rst(rst),

    .cache_enable(cache_enable),
    .write_index(write_index),
    .index_sel(index_sel),
    .rd_wr_sel(lsu_operator),
    .read_data(read_data)
);

logic hit_miss; //Hit = 1, Miss = 0
logic access; //Access Signal
//logic [data-1:0] dram_data_input_reg;
logic stall_reg;
logic [tag+data:0] write_index_reg;
logic [tag-1:0] input_tag; //Derived from the Address
logic mem_req_reg;

assign input_tag = address[tag + data - 1:data];
assign stall = stall_reg;
//assign dram_data_input_reg = dram_data_input;
assign write_index = write_index_reg;
assign mem_req = mem_req_reg;
assign access = mem_enable ? 1 : 0;

typedef enum logic [1:0]{
    IDLE = 2'b00, //Go here when RESET
    ACCESS = 2'b01, //When Memory is enabled go here
    HIT = 2'b10,   //hit_miss = 1
    MISS_REPAIR = 2'b11 //hit_miss = 0
} state_t;
state_t current, next;

//State Transition
always_ff @(posedge clk) begin 
    if (rst) begin
        current <= IDLE;
    end else begin
        current <= next;
    end
end

//Begin Sequential Logic
always_ff @(posedge clk) begin
    if (rst) begin
        access = 1'd0;
        stall_reg = 1'd0;  
        mem_req_req = 1'd0;
    end else begin
        case(current)
            IDLE: begin
                stall_reg = 1'd0;
                mem_req_req = 1'd0;
            end
            ACCESS: begin
                stall_reg = 1'd0;
                mem_req_req = 1'd0;
            end
            HIT: begin
                stall_reg = 1'd0;
                mem_req_req = 1'd0;
                cache_enable = 1'd1; 
                if (lsu_operator)  
            end
            MISS_REPAIR: begin 
                stall_reg = 1'd1;
                mem_req_req = 1'd1;
                cache_enable = 1'd1;
            end
        endcase
    end
end

always_comb





endmodule