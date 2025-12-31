//Data Cache
module data_cache #(parameter index_count = 256,
parameter data = 11, parameter tag = 20)
(
    input logic wr_en,
    input logic rd_en,
    input logic [data - 1:0] wr_data,
    input logic [index_count - 1:0] index_sel,
    input logic [tag - 1:0] input_tag,
    output wire [data - 1:0] read_data,
    output logic [data - 1:0] write_data,
    output logic hit_miss,
    output logic data_req,
    output logic mem_ready,
    output logic [data - 1:0] dram_input
);

logic [data - 1:0] write_hit_data;
logic hit_miss_int;
logic compared_value; //Comparator output
logic [tag + data:0] cache_data; //Cache Data = {Valid, Tag, Data}
logic [data - 1:0] dram_input_int;


logic [data - 1:0] data_reg;
logic [tag - 1:0] internal_tag;
logic valid;


assign hit_miss = hit_miss_int;
assign data_req = hit_miss_int;

assign read_data = rd_en && ~hit_miss_int && data; //Read the Data output
assign write_data = wr_en && ~hit_miss_int && data; //Send Data to the DRAM
assign write_hit_data = ~(hit_miss_int) && write_data; //Write Data

assign dram_input = dram_input_int;


//Creating the Data Array (Filling Cache with arbitrary values)
genvar index; 
generate
    always_comb begin
        for (index = 0; index < index_count; index++) begin //Create an index from 0 to 255
            cache_data[index] = {1, 20'd18575, 11'd135};
        end
    end
endgenerate

//Cache Line Select
always_comb begin 
    case(index_sel):
        data_reg = cache_data[index_sel][data - 1:0];
        internal_tag = cache_data[index_sel][tag + data - 1: data];
        valid = cache_data[index_sel][tag+data];
    endcase    

    //Comparator
    if ((input_tag - tag) == 1'd0){
        compared_value = 1'b1; //Values Match
    }
    else{
        compared_value = 1'b0; //Values do NOT Match
    }
    hit_miss_int = ~(compared_value & valid);
    dram_input_int = (data_req & mem_ready) && dram_input;
end

//On a Miss
always_comb begin
    if (dram_input_int){
            case(index_sel):
                cache_data[index_sel] = dram_input_int;
            endcase
    }
end

//On a Write-Hit
always_comb begin
    if (write_hit_data){
        case(index_sel):
            cache_data[index_sel][data - 1:0] = write_hit_data;
        endcase
    }
end

endmodule