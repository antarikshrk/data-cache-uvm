//Data Cache
module data_cache #(parameter index_count = 256,
parameter data = 11, parameter tag = 20)
(
    input wire clk,
    input wire rst,
    input logic cache_enable, //Enable the Cache
    input logic [tag + data:0] write_data, //Write Data to the Cache (Specific Data provided by Controller)
    input logic [$clog2(index_count) - 1:0] index_sel, //Index Select
    input logic rd_wr_sel, //Read/Write Select

    output wire [data - 1:0] read_data, //Data being Read from Cache
);

logic [7:0] cache_data[index_count-1:0]; //256 Lines containing {valid, tag, data}
logic [data - 1:0] read_data_reg;

assign read_data = read_data_reg; //For Procedural Block

initial begin
    for (int index = 0; index < index_count; index++){
        cache_data[index] = 1'd0; //Initialize the Cache 
    }
end

always_ff @(posedge clk) begin
    if (rst) begin
        cache_data[index_sel][tag+data] = 1'd0; //Reset the Valid bits to 0
    end else begin
        if (cache_enable) begin
            case(rd_wr_sel): //Read = 0, Write = 1
                1'd0: read_data_reg = cache_data[index_sel][data - 1:0]; //Read Data
                1'd1: cache_data[index_sel] = write_data ; //Write Data
            endcase
        end
    end
end


endmodule