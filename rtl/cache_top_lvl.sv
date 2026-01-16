//Cache Top Level File -> Instantiating Cache Controller <-> DRAM
import cache_pkg::*;

module cache_level_top #(
    parameter INDEX_COUNT = cache_pkg::INDEX_COUNT,
    parameter DATA_WIDTH = cache_pkg::DATA_WIDTH,
    parameter TAG_WIDTH = cache_pkg::TAG_WIDTH
)(
    input wire clk,
    input wire rst,
    input wire [31:0] address,
    input lsu_ops lsu_operator,
    input wire mem_enable,

    output wire stall,
    output wire [DATA_WIDTH-1:0] read_data
);

//Internal wires that connect controller and DRAM
logic mem_req;
logic mem_ready;
logic [DATA_WIDTH-1:0] dram_data_in; //Data from the DRAM
logic [DATA_WIDTH-1:0] write_data_dram; //Data to the DRAM


//Instantiate the Cache Controller
cache_controller #(
    .index_count(INDEX_COUNT),
    .data(DATA_WIDTH),
    .tag(TAG_WIDTH)
) cache_contrl(
    .clk(clk),
    .rst(rst),
    .address(address),
    .lsu_operator(lsu_operator),
    .mem_enable(mem_enable),
    .mem_ready(mem_ready),
    .dram_data_input(dram_data_in),
    .mem_req(mem_req),
    .write_data_int(write_data_dram),
    .stall(stall),
    .read_data(read_data)
);

//Instantiate the DRAM
dummy_dram #(
    .data(DATA_WIDTH),
    .tag(TAG_WIDTH)
) dram(
    .clk(clk),
    .rst(rst),
    .address(address),
    .lsu_operator(lsu_operator),
    .mem_req(mem_req),
    .write_data_int(write_data_dram),
    .mem_ready(mem_ready),
    .dram_data_out(dram_data_in)
);

endmodule
