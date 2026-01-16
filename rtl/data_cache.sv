//Data Cache -> Not sure what to do with the Offset
import cache_pkg::*;

module data_cache #(
    parameter index_count = 256,
    parameter data, 
    parameter tag
)(
    input wire clk,
    input wire rst,
    input logic cache_enable, //Enable the Cache
    input logic [tag + data:0] write_index, //Write Data to the Cache (Includes {updated_valid, updated_tag, updated_data})
    input logic [$clog2(index_count) - 1:0] index_sel, //Index Select
    input lsu_ops rd_wr_sel, //Read/Write Select

    output wire [data - 1:0] read_data, //Data being Read from Cache
    output logic [tag + data - 1: data] cache_tag, //The Tag from the Cache
    output logic [data-1:0] write_data_int, //Write Data to the DRAM
    output logic cache_valid,
    output logic [data-1:0] cache_data_io
);

logic [tag+data:0] cache_data[0:index_count-1]; //256 Lines containing {valid, tag, data}
logic [data - 1:0] read_data_reg;
assign read_data = read_data_reg; //For Procedural Block

initial begin
    for (int index = 0; index < index_count; index=index+1)
        cache_data[index] = 0; //Initialize the Cache 
end

integer i;
always_ff @(posedge clk) begin
    if (rst) begin
        //cache_data[index_sel][tag+data] = 1'd0; //Reset the Valid bits to 0
        for (i = 0; i < index_count; i++)
            cache_data[i][tag+data] <= 1'd0; //Reset the Valid bits to 0
    end else begin
        if (cache_enable) begin
            case(rd_wr_sel) //Read = 0, Write = 1
                LW: begin
                    read_data_reg <= cache_data[index_sel][data - 1:0]; //Read Data
                end
                SW: begin
                    cache_data[index_sel][tag + data:0] <= write_index ; //Write Data 
                end
            endcase
        end
    end
end

assign cache_tag = cache_data[index_sel][tag + data - 1:data];
assign cache_valid = cache_data[index_sel][tag+data];
assign cache_data_io = cache_data[index_sel][data-1:0];


endmodule